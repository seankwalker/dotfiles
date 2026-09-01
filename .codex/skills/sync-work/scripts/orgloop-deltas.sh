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

DAY_START_EPOCH="$(parse_local_midnight "$SYNC_DATE")" || exit 2
(( CUTOFF_EPOCH >= DAY_START_EPOCH )) || exit 2

CODEX_DATA_DIR="${CODEX_HOME:-$HOME/.codex}"
STATE_DIR="${SYNC_WORK_STATE_DIR:-$CODEX_DATA_DIR/workflow/sync-work}"
CURSOR_FILE="$STATE_DIR/$SYNC_DATE.cursor"
PENDING_FILE="$STATE_DIR/$SYNC_DATE.orgloop-pending.json"
DRIVER_IDS_FILE="$STATE_DIR/driver-threads"
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

command -v jq >/dev/null || exit 2
mkdir -p "$STATE_DIR"

DRIVER_THREAD_ID="${CODEX_THREAD_ID:-}"
if [[ -n "$DRIVER_THREAD_ID" ]] && ! grep -qxF "$DRIVER_THREAD_ID" "$DRIVER_IDS_FILE" 2>/dev/null; then
  printf '%s\n' "$DRIVER_THREAD_ID" >> "$DRIVER_IDS_FILE"
fi

if [[ ! -f "$PENDING_FILE" ]]; then
  ORGLOOP_ENTRY="${SYNC_WORK_ORGLOOP_ENTRY:-$HOME/Developer/orgloop/packages/cli/dist/index.js}"
  ORGLOOP_NODE="${SYNC_WORK_ORGLOOP_NODE:-$HOME/.local/share/mise/installs/node/24.15.0/bin/node}"
  [[ -x "$ORGLOOP_NODE" && -f "$ORGLOOP_ENTRY" ]] || exit 2

  TMP_FILE="$(mktemp "$STATE_DIR/.${SYNC_DATE}.orgloop-pending.XXXXXX")"
  trap 'rm -f "$TMP_FILE"' EXIT
  if ! "$ORGLOOP_NODE" "$ORGLOOP_ENTRY" --json inbox drain \
    --key codex:driver:worker-completions --limit 250 --format json > "$TMP_FILE" 2>/dev/null; then
    exit 2
  fi
  jq -e '.events | arrays' "$TMP_FILE" >/dev/null || exit 2
  mv "$TMP_FILE" "$PENDING_FILE"
  trap - EXIT
fi

SINCE_UTC="$(format_utc "$SINCE_EPOCH")"
CUTOFF_UTC="$(format_utc "$CUTOFF_EPOCH")"
DRIVER_IDS_JSON='[]'
if [[ -f "$DRIVER_IDS_FILE" ]]; then
  DRIVER_IDS_JSON="$(jq -Rn '[inputs | select(length > 0)]' < "$DRIVER_IDS_FILE")"
fi

jq \
  --arg date "$SYNC_DATE" \
  --arg cursor_source "$CURSOR_SOURCE" \
  --arg since_utc "$SINCE_UTC" \
  --arg cutoff_utc "$CUTOFF_UTC" \
  --argjson since_epoch "$SINCE_EPOCH" \
  --argjson cutoff_epoch "$CUTOFF_EPOCH" \
  --argjson driver_ids "$DRIVER_IDS_JSON" '
    def clip($limit):
      tostring | if length > $limit then .[0:$limit] + "…[truncated]" else . end;
    def session_id: .payload.session_id // .payload.session.id // "unknown";
    .events as $all
    | [$all[] | select(.timestamp > $since_utc and .timestamp <= $cutoff_utc)] as $window
    | [$window[] | select((session_id as $id | $driver_ids | index($id)) | not)] as $workers
    | {
        date: $date,
        source: "orgloop",
        cursor_source: $cursor_source,
        since_epoch: $since_epoch,
        since_utc: $since_utc,
        cutoff_epoch: $cutoff_epoch,
        cutoff_utc: $cutoff_utc,
        drained_event_count: ($all | length),
        ignored_driver_events: (($window | length) - ($workers | length)),
        ignored_out_of_window_events: (($all | length) - ($window | length)),
        remaining: (.remaining // 0),
        sessions: (
          $workers
          | sort_by(session_id, .timestamp)
          | group_by(session_id)
          | map(.[-1])
          | map({
              id: session_id,
              title: ((.payload.final_assistant_handoff // "Codex worker completion") | split("\n")[0] | clip(180)),
              cwd: (.payload.cwd // .payload.session.cwd // null),
              git_branch: null,
              latest_activity_utc: .timestamp,
              lifecycle: {
                state: "idle",
                last_event: {timestamp: .timestamp, event: "task_complete"}
              },
              messages: (
                if ((.payload.final_assistant_handoff // "") | length) > 0 then
                  [{
                    timestamp: .timestamp,
                    role: "assistant",
                    phase: "final_answer",
                    text: (.payload.final_assistant_handoff | clip(1600))
                  }]
                else [] end
              ),
              has_final_handoff: (((.payload.final_assistant_handoff // "") | length) > 0)
            })
        )
      }
  ' "$PENDING_FILE"
