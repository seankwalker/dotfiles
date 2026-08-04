#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "usage: ${0##*/} <root-thread-id> <start-utc> <cutoff-utc>" >&2
  exit 1
}

[[ $# -eq 3 ]] || usage

ROOT_THREAD_ID="$1"
START_UTC="$2"
CUTOFF_UTC="$3"

[[ "$ROOT_THREAD_ID" =~ ^[0-9a-f-]+$ ]] || usage

parse_utc() {
  local value="$1"
  if TZ=UTC date -j -f '%Y-%m-%dT%H:%M:%SZ' "$value" '+%s' 2>/dev/null; then
    return
  fi
  TZ=UTC date -d "$value" '+%s' 2>/dev/null
}

START_EPOCH="$(parse_utc "$START_UTC")" || usage
CUTOFF_EPOCH="$(parse_utc "$CUTOFF_UTC")" || usage

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

{
  while IFS=$'\t' read -r THREAD_ID ROLLOUT_PATH; do
    [[ -f "$ROLLOUT_PATH" ]] || continue

    jq -c \
      --arg thread_id "$THREAD_ID" \
      --arg start "$START_UTC" \
      --arg cutoff "$CUTOFF_UTC" '
      def clip($limit):
        tostring
        | if length > $limit then .[0:$limit] + "…[truncated]" else . end;
      def message_text:
        [.payload.content[]? | .text? // empty] | join("\n");

      select(.timestamp >= $start and .timestamp <= $cutoff)
      | if .type == "response_item" and .payload.type == "message" then
          message_text as $text
          | select(($text | startswith("<environment_context>")) | not)
          | {
              timestamp,
              thread_id: $thread_id,
              kind: "message",
              role: .payload.role,
              text: ($text | clip(4000))
            }
        elif .type == "response_item"
          and (.payload.type == "custom_tool_call" or .payload.type == "function_call") then
          {
            timestamp,
            thread_id: $thread_id,
            kind: "tool_call",
            name: .payload.name,
            call_id: .payload.call_id,
            detail: ((.payload.input // .payload.arguments // "") | clip(2000))
          }
        elif .type == "response_item"
          and (.payload.type == "custom_tool_call_output" or .payload.type == "function_call_output") then
          (.payload.output | tostring) as $output
          | {
              timestamp,
              thread_id: $thread_id,
              kind: "tool_output",
              call_id: .payload.call_id,
              chars: ($output | length),
              detail: ($output | clip(2500))
            }
        elif .type == "event_msg"
          and (.payload.type == "task_started"
            or .payload.type == "task_complete"
            or .payload.type == "context_compacted"
            or .payload.type == "turn_aborted") then
          {
            timestamp,
            thread_id: $thread_id,
            kind: .payload.type,
            detail: ((.payload.last_agent_message // .payload.reason // "") | clip(2500))
          }
        elif .type == "compacted" then
          {
            timestamp,
            thread_id: $thread_id,
            kind: "compaction_summary",
            detail: (.payload | clip(2500))
          }
        else
          empty
        end
    ' "$ROLLOUT_PATH"
  done < <(
    sqlite3 -separator $'\t' "$STATE_DB" "
WITH RECURSIVE tree(id) AS (
  SELECT '$ROOT_THREAD_ID'
  UNION ALL
  SELECT edges.child_thread_id
  FROM tree
  JOIN thread_spawn_edges AS edges ON edges.parent_thread_id = tree.id
)
SELECT threads.id, threads.rollout_path
FROM tree
JOIN threads ON threads.id = tree.id
WHERE threads.updated_at >= $START_EPOCH
  AND threads.created_at <= $CUTOFF_EPOCH
  AND threads.rollout_path <> '';
"
  )
} | jq -sc \
  --arg root_thread_id "$ROOT_THREAD_ID" \
  --arg start_utc "$START_UTC" \
  --arg cutoff_utc "$CUTOFF_UTC" '
  def friction_signal($tool_name):
    (.detail // "") as $detail
    | .kind == "tool_output"
      and (
        .chars >= 12000
        or ($detail | test("Warning: truncated output|original token count"; "i"))
        or (
          if $tool_name == "exec" then
            ($detail | test("Script failed|process exited with code|\\\"exit_code\\\":[1-9]"; "i"))
          elif $tool_name == "wait_agent" or $tool_name == "wait" then
            ($detail | test("Wait timed out|\\\"timed_out\\\":true"; "i"))
          elif $tool_name == "spawn_agent" then
            ($detail | test("spawn failed|limit reached"; "i"))
          else
            ($detail | test("\\\"isError\\\":true|tool call failed"; "i"))
          end
        )
      );

  def signal_category($tool_name):
    (.detail // "") as $detail
    | if (($tool_name == "wait_agent" or $tool_name == "wait")
      and ($detail | test("timed out|timeout"; "i"))) then
        "timeout"
      elif (($detail | test("Script failed|process exited with code|\\\"exit_code\\\":[1-9]"; "i"))
        and ($detail | test("conflict|MERGE_HEAD"; "i"))) then
        "merge-conflict"
      elif (($detail | test("Script failed|process exited with code|\\\"exit_code\\\":[1-9]"; "i"))
        and ($detail | test("not found|no such file|command not found|ERR_MODULE_NOT_FOUND|missing"; "i"))) then
        "missing-dependency-or-path"
      elif (($detail | test("Script failed|process exited with code|\\\"exit_code\\\":[1-9]"; "i"))
        and ($detail | test("unsupported|unknown option|invalid option|usage:"; "i"))) then
        "invalid-command-or-option"
      elif ($detail | test("Script failed|process exited with code|\\\"exit_code\\\":[1-9]|spawn failed|limit reached|\\\"isError\\\":true|tool call failed"; "i")) then
        "command-or-tool-failure"
      elif (.chars >= 12000 or ($detail | test("truncated output|original token count"; "i"))) then
        "large-or-truncated-output"
      else
        "warning"
      end;

  . as $events
  | (reduce ($events[] | select(.kind == "tool_call")) as $call
      ({}; .[$call.call_id] = $call)) as $calls
  | [
      $events[]
      | select(.kind == "tool_output")
      | . as $output
      | ($calls[$output.call_id] // {}) as $call
      | select($output | friction_signal($call.name))
      | {
          timestamp: $output.timestamp,
          thread_id: $output.thread_id,
          category: ($output | signal_category($call.name)),
          name: $call.name,
          input: $call.detail,
          chars: $output.chars,
          detail: $output.detail
        }
    ] as $signals
  | {
      root_thread_id: $root_thread_id,
      start_utc: $start_utc,
      cutoff_utc: $cutoff_utc,
      events: [
        $events[]
        | select(
            (.thread_id == $root_thread_id and .kind == "message")
            or .kind == "task_complete"
            or .kind == "context_compacted"
            or .kind == "compaction_summary"
            or .kind == "turn_aborted"
          )
      ] | sort_by(.timestamp),
      tool_signals: (
        $signals
        | group_by(.category)
        | map(
            sort_by(if .thread_id == $root_thread_id then 0 else 1 end, .timestamp)
            | {
                category: .[0].category,
                occurrences: length,
                first_timestamp: (map(.timestamp) | min),
                last_timestamp: (map(.timestamp) | max),
                max_output_chars: (map(.chars) | max),
                tools: (
                  group_by(.name)
                  | map({name: .[0].name, count: length})
                  | sort_by(-.count)
                ),
                samples: .[0:3]
              }
          )
        | sort_by(.category)
      )
    }
'
