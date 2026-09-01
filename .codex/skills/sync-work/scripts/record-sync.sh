#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "usage: ${0##*/} <YYYY-MM-DD> <cutoff-epoch>" >&2
  exit 1
}

[[ $# -eq 2 ]] || usage
SYNC_DATE="$1"
CUTOFF_EPOCH="$2"

[[ "$SYNC_DATE" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] || usage
[[ "$CUTOFF_EPOCH" =~ ^[0-9]+$ ]] || usage

CODEX_DATA_DIR="${CODEX_HOME:-$HOME/.codex}"
STATE_DIR="${SYNC_WORK_STATE_DIR:-$CODEX_DATA_DIR/workflow/sync-work}"
mkdir -p "$STATE_DIR"

TMP_FILE="$(mktemp "$STATE_DIR/.${SYNC_DATE}.cursor.XXXXXX")"
trap 'rm -f "$TMP_FILE"' EXIT
printf '%s\n' "$CUTOFF_EPOCH" > "$TMP_FILE"
mv "$TMP_FILE" "$STATE_DIR/$SYNC_DATE.cursor"
rm -f "$STATE_DIR/$SYNC_DATE.orgloop-pending.json"
trap - EXIT
