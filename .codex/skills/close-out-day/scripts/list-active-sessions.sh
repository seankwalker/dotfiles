#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "usage: ${0##*/} [YYYY-MM-DD] [cutoff-epoch]" >&2
  exit 1
}

[[ $# -le 2 ]] || usage

AUDIT_DATE="${1:-$(TZ=America/Los_Angeles date +%F)}"
CUTOFF_EPOCH="${2:-$(date +%s)}"

[[ "$AUDIT_DATE" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] || usage
[[ "$CUTOFF_EPOCH" =~ ^[0-9]+$ ]] || usage

if START_EPOCH="$(TZ=America/Los_Angeles date -j -f '%Y-%m-%d %H:%M:%S' "$AUDIT_DATE 00:00:00" '+%s' 2>/dev/null)"; then
  :
elif START_EPOCH="$(TZ=America/Los_Angeles date -d "$AUDIT_DATE 00:00:00" '+%s' 2>/dev/null)"; then
  :
else
  echo "error: could not parse date: $AUDIT_DATE" >&2
  exit 1
fi

if (( CUTOFF_EPOCH < START_EPOCH )); then
  echo "error: cutoff precedes the start of $AUDIT_DATE" >&2
  exit 1
fi

CODEX_DATA_DIR="${CODEX_HOME:-$HOME/.codex}"
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
command -v sqlite3 >/dev/null || {
  echo "error: sqlite3 is required" >&2
  exit 1
}
command -v jq >/dev/null || {
  echo "error: jq is required" >&2
  exit 1
}

SESSIONS_JSON="$(sqlite3 -json "$STATE_DB" "
WITH RECURSIVE
active(id) AS (
  SELECT id
  FROM threads
  WHERE updated_at >= $START_EPOCH AND updated_at <= $CUTOFF_EPOCH
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
  WHERE parent_edge.child_thread_id IS NULL AND threads.title <> ''
),
tree(root_id, id) AS (
  SELECT id, id FROM roots
  UNION ALL
  SELECT tree.root_id, edges.child_thread_id
  FROM tree
  JOIN thread_spawn_edges AS edges ON edges.parent_thread_id = tree.id
),
activity AS (
  SELECT
    tree.root_id,
    MAX(threads.updated_at) AS latest_activity,
    SUM(
      CASE
        WHEN tree.id <> tree.root_id
          AND threads.updated_at >= $START_EPOCH
          AND threads.updated_at <= $CUTOFF_EPOCH
        THEN 1 ELSE 0
      END
    ) AS active_descendants
  FROM tree
  JOIN threads ON threads.id = tree.id
  WHERE threads.updated_at >= $START_EPOCH AND threads.updated_at <= $CUTOFF_EPOCH
  GROUP BY tree.root_id
)
SELECT
  threads.id,
  substr(
    replace(replace(threads.title, char(10), ' '), char(13), ' '),
    1,
    160
  ) AS title,
  threads.cwd,
  threads.rollout_path,
  strftime('%Y-%m-%dT%H:%M:%SZ', activity.latest_activity, 'unixepoch') AS latest_activity_utc,
  activity.active_descendants
FROM roots
JOIN threads ON threads.id = roots.id
JOIN activity ON activity.root_id = roots.id
ORDER BY activity.latest_activity;
")"

[[ -n "$SESSIONS_JSON" ]] || SESSIONS_JSON='[]'

START_UTC="$(TZ=UTC date -r "$START_EPOCH" '+%Y-%m-%dT%H:%M:%SZ')"
CUTOFF_UTC="$(TZ=UTC date -r "$CUTOFF_EPOCH" '+%Y-%m-%dT%H:%M:%SZ')"

jq -n \
  --arg date "$AUDIT_DATE" \
  --arg start_utc "$START_UTC" \
  --arg cutoff_utc "$CUTOFF_UTC" \
  --argjson start_epoch "$START_EPOCH" \
  --argjson cutoff_epoch "$CUTOFF_EPOCH" \
  --argjson sessions "$SESSIONS_JSON" \
  '{date: $date, start_utc: $start_utc, cutoff_utc: $cutoff_utc, start_epoch: $start_epoch, cutoff_epoch: $cutoff_epoch, sessions: $sessions}'
