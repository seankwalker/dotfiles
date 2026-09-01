#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "usage: ${0##*/} [YYYY-MM-DD] [cutoff-epoch]" >&2
  exit 1
}

[[ $# -le 2 ]] || usage

SYNC_DATE="${1:-$(TZ=America/Los_Angeles date +%F)}"
CUTOFF_EPOCH="${2:-$(date +%s)}"

[[ "$SYNC_DATE" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] || usage
[[ "$CUTOFF_EPOCH" =~ ^[0-9]+$ ]] || usage

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
if [[ "${SYNC_WORK_SOURCE:-prefer-orgloop}" != "sqlite" ]]; then
  if "$SCRIPT_DIR/orgloop-deltas.sh" "$SYNC_DATE" "$CUTOFF_EPOCH"; then
    exit 0
  fi
  if [[ "${SYNC_WORK_SOURCE:-prefer-orgloop}" == "orgloop" ]]; then
    echo "error: Orgloop inbox is unavailable" >&2
    exit 1
  fi
  echo "warning: Orgloop inbox unavailable; falling back to Codex SQLite" >&2
fi

parse_local_midnight() {
  local value="$1"
  if TZ=America/Los_Angeles date -j -f '%Y-%m-%d %H:%M:%S' "$value 00:00:00" '+%s' 2>/dev/null; then
    return
  fi
  TZ=America/Los_Angeles date -d "$value 00:00:00" '+%s' 2>/dev/null
}

format_utc() {
  local value="$1"
  if TZ=UTC date -r "$value" '+%Y-%m-%dT%H:%M:%SZ' 2>/dev/null; then
    return
  fi
  TZ=UTC date -d "@$value" '+%Y-%m-%dT%H:%M:%SZ' 2>/dev/null
}

DAY_START_EPOCH="$(parse_local_midnight "$SYNC_DATE")" || {
  echo "error: could not parse date: $SYNC_DATE" >&2
  exit 1
}

if (( CUTOFF_EPOCH < DAY_START_EPOCH )); then
  echo "error: cutoff precedes the start of $SYNC_DATE" >&2
  exit 1
fi

CODEX_DATA_DIR="${CODEX_HOME:-$HOME/.codex}"
STATE_DIR="${SYNC_WORK_STATE_DIR:-$CODEX_DATA_DIR/workflow/sync-work}"
CURSOR_FILE="$STATE_DIR/$SYNC_DATE.cursor"
SINCE_EPOCH="$DAY_START_EPOCH"
CURSOR_SOURCE="start-of-day"

if [[ -f "$CURSOR_FILE" ]]; then
  CURSOR_VALUE="$(<"$CURSOR_FILE")"
  if [[ "$CURSOR_VALUE" =~ ^[0-9]+$ ]] \
    && (( CURSOR_VALUE >= DAY_START_EPOCH )) \
    && (( CURSOR_VALUE <= CUTOFF_EPOCH )); then
    SINCE_EPOCH="$CURSOR_VALUE"
    CURSOR_SOURCE="previous-sync"
  fi
fi

STATE_DB="${CODEX_STATE_DB:-}"
if [[ -z "$STATE_DB" ]]; then
  shopt -s nullglob
  STATE_DBS=("$CODEX_DATA_DIR"/state_*.sqlite)
  shopt -u nullglob
  ((${#STATE_DBS[@]} > 0)) || {
    echo "error: no Codex state database found in $CODEX_DATA_DIR" >&2
    exit 1
  }
  STATE_DB="$(ls -t "${STATE_DBS[@]}" | head -n 1)"
fi

[[ -f "$STATE_DB" ]] || {
  echo "error: Codex state database not found: $STATE_DB" >&2
  exit 1
}
command -v sqlite3 >/dev/null || { echo "error: sqlite3 is required" >&2; exit 1; }
command -v jq >/dev/null || { echo "error: jq is required" >&2; exit 1; }

DRIVER_THREAD_ID="${CODEX_THREAD_ID:-}"
SINCE_UTC="$(format_utc "$SINCE_EPOCH")"
CUTOFF_UTC="$(format_utc "$CUTOFF_EPOCH")"

SESSIONS_JSON="$(sqlite3 -json "$STATE_DB" "
WITH RECURSIVE
active(id) AS (
  SELECT id FROM threads
  WHERE updated_at > $SINCE_EPOCH AND updated_at <= $CUTOFF_EPOCH
),
ancestors(id) AS (
  SELECT id FROM active
  UNION
  SELECT edges.parent_thread_id
  FROM thread_spawn_edges AS edges
  JOIN ancestors ON edges.child_thread_id = ancestors.id
),
roots(id) AS (
  SELECT DISTINCT ancestors.id
  FROM ancestors
  JOIN threads ON threads.id = ancestors.id
  LEFT JOIN thread_spawn_edges AS parent_edge
    ON parent_edge.child_thread_id = ancestors.id
  WHERE parent_edge.child_thread_id IS NULL
    AND threads.title <> ''
    AND threads.id <> '$DRIVER_THREAD_ID'
),
tree(root_id, id) AS (
  SELECT id, id FROM roots
  UNION ALL
  SELECT tree.root_id, edges.child_thread_id
  FROM tree
  JOIN thread_spawn_edges AS edges ON edges.parent_thread_id = tree.id
),
activity AS (
  SELECT tree.root_id, MAX(threads.updated_at) AS latest_activity
  FROM tree
  JOIN threads ON threads.id = tree.id
  WHERE threads.updated_at > $SINCE_EPOCH AND threads.updated_at <= $CUTOFF_EPOCH
  GROUP BY tree.root_id
)
SELECT
  threads.id,
  substr(replace(replace(threads.title, char(10), ' '), char(13), ' '), 1, 180) AS title,
  threads.cwd,
  threads.rollout_path,
  threads.git_branch,
  strftime('%Y-%m-%dT%H:%M:%SZ', activity.latest_activity, 'unixepoch') AS latest_activity_utc
FROM roots
JOIN threads ON threads.id = roots.id
JOIN activity ON activity.root_id = roots.id
ORDER BY activity.latest_activity;
")"
[[ -n "$SESSIONS_JSON" ]] || SESSIONS_JSON='[]'

RESULTS_FILE="$(mktemp)"
trap 'rm -f "$RESULTS_FILE"' EXIT

while IFS= read -r session; do
  ROLLOUT_PATH="$(jq -r '.rollout_path' <<<"$session")"
  [[ -f "$ROLLOUT_PATH" ]] || continue

  MESSAGES="$(jq -sc \
    --arg start "$SINCE_UTC" \
    --arg cutoff "$CUTOFF_UTC" '
      def clip($limit):
        tostring | if length > $limit then .[0:$limit] + "…[truncated]" else . end;
      def message_text: [.payload.content[]? | .text? // empty] | join("\n");
      [
        .[]
        | select(.timestamp > $start and .timestamp <= $cutoff)
        | select(.type == "response_item" and .payload.type == "message")
        | message_text as $text
        | select(($text | startswith("<environment_context>")) | not)
        | {
            timestamp,
            role: .payload.role,
            phase: (.payload.phase // null),
            text: ($text | clip(1600))
          }
      ][-6:]
    ' "$ROLLOUT_PATH")"

  LIFECYCLE="$(jq -sc \
    --arg cutoff "$CUTOFF_UTC" '
      [
        .[]
        | select(.timestamp <= $cutoff)
        | select(.type == "event_msg")
        | select(.payload.type == "task_started" or .payload.type == "task_complete" or .payload.type == "turn_aborted")
        | {timestamp, event: .payload.type}
      ]
      | if length == 0 then
          {state: "unknown", last_event: null}
        elif .[-1].event == "task_started" then
          {state: "active", last_event: .[-1]}
        else
          {state: "idle", last_event: .[-1]}
        end
    ' "$ROLLOUT_PATH")"

  jq -cn \
    --argjson session "$session" \
    --argjson messages "$MESSAGES" \
    --argjson lifecycle "$LIFECYCLE" '
      $session
      | del(.rollout_path)
      | . + {
          lifecycle: $lifecycle,
          messages: $messages,
          has_final_handoff: ([$messages[] | select(.role == "assistant" and .phase == "final_answer")] | length > 0)
        }
    ' >> "$RESULTS_FILE"
done < <(jq -c '.[]' <<<"$SESSIONS_JSON")

jq -n \
  --arg date "$SYNC_DATE" \
  --arg cursor_source "$CURSOR_SOURCE" \
  --arg since_utc "$SINCE_UTC" \
  --arg cutoff_utc "$CUTOFF_UTC" \
  --argjson since_epoch "$SINCE_EPOCH" \
  --argjson cutoff_epoch "$CUTOFF_EPOCH" \
  --slurpfile sessions "$RESULTS_FILE" '
    {
      date: $date,
      cursor_source: $cursor_source,
      since_epoch: $since_epoch,
      since_utc: $since_utc,
      cutoff_epoch: $cutoff_epoch,
      cutoff_utc: $cutoff_utc,
      sessions: $sessions
    }
  '
