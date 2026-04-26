#!/usr/bin/env bash
# Attach to a tmux session that tails each agent log.
set -euo pipefail

SESSION=${TMUX_SESSION:-agents}
WORKSPACE_ROOT=${WORKSPACE_ROOT:-/agents/workspace}
LOG_NAME=${LOG_NAME:-agent.log}

if ! command -v tmux >/dev/null 2>&1; then
  echo "tmux is not installed in this container" >&2
  exit 1
fi

if tmux has-session -t "$SESSION" 2>/dev/null; then
  exec tmux attach -t "$SESSION"
fi

mapfile -t AGENTS < <(ls -d ${WORKSPACE_ROOT}/agent-* 2>/dev/null || true)
if [ ${#AGENTS[@]} -eq 0 ]; then
  echo "No agent workspaces found under ${WORKSPACE_ROOT}" >&2
  exit 1
fi

first="${AGENTS[0]}"
LOG_PATH="${first}/${LOG_NAME}"
if [ ! -f "$LOG_PATH" ]; then
  touch "$LOG_PATH"
fi

tmux new-session -d -s "$SESSION" "tail -f '$LOG_PATH'"

for agent_dir in "${AGENTS[@]:1}"; do
  log="$agent_dir/$LOG_NAME"
  [ -f "$log" ] || touch "$log"
  tmux split-window -t "$SESSION" -v "tail -f '$log'"
  tmux select-layout -t "$SESSION" tiled > /dev/null
fi

tmux attach -t "$SESSION"
