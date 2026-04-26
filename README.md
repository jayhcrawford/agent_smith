# Agent Smith

Agent Smith is an A→Z toolkit for launching an isolated Docker container that can host multiple OpenClaw-style agents at once. Each agent gets its own workspace inside the container, keeping the host machine clean while still allowing GitHub access via SSH or other auth methods.

## Goals
- **Isolation:** Agents run inside a containerized environment separate from the host file system.
- **Parallelism:** Spin up N agents (default 4) without juggling multiple VMs/containers.
- **Safety:** No agent has unilateral authority to modify multiple repos at once; cross-repo work requires explicit human coordination.
- **Clarity:** Docs/scripts stay accurate so humans can audit quickly.

## Repo Layout (in progress)
```
agent_smith/
├─ docker/
│  ├─ Dockerfile              # Builds the container image
│  ├─ entrypoint.sh           # Boots supervisor + agents
├─ scripts/
│  ├─ start_agents.sh         # Build + run container (bind mounts workspace)
│  ├─ add_agent.sh            # (stub) future IPC to add agents
│  ├─ remove_agent.sh         # (stub) future IPC to remove agents
│  ├─ dummy_agent.sh          # heartbeat logger used today
│  └─ watch_logs.sh           # tmux tail of agent logs
├─ supervisor/
│  ├─ config.yaml             # Agent binary/env settings
│  ├─ supervisor.py           # Spawns placeholder agents
├─ workspace/
│  └─ agent-*/agent.log       # Per-agent logs created at runtime
```

## Runtime Flow
1. `./scripts/start_agents.sh` builds the Docker image and launches the container with `AGENT_COUNT` (default 4).
2. Entrypoint runs `/agent_smith/supervisor/supervisor.py --agent-count $AGENT_COUNT`.
3. Supervisor creates per-agent workspaces under `/agents/workspace/agent-{n}`.
4. Dummy agents log heartbeats to `agent.log` in each workspace (real agent process to be wired later).
5. Helper scripts will eventually add/remove agents via IPC; currently they stub out the signals.

## Quick Start
```
./scripts/start_agents.sh            # build + run, default 4 agents
AGENT_COUNT=6 ./scripts/start_agents.sh
```
- `workspace/` is bind-mounted into the container (agents write logs there).
- Container stops when you CTRL+C the process.

## Watching Logs
Run from the host to attach to tmux tails inside the container:
```
docker exec -it agent-smith /agent_smith/scripts/watch_logs.sh
```
This creates/attaches to a tmux session tailing `workspace/agent-*/agent.log`. Detach with `Ctrl+b d`.

## Testing the Skeleton
- Dummy agents (`scripts/dummy_agent.sh`) are what currently run; they only log heartbeats.
- As we wire real agents, update `supervisor/config.yaml` to point to the correct binary.
- Add/remove scripts are placeholders until supervisor IPC is implemented.

## Constraints / Policies
- One repo per agent. Cross-repo work must be coordinated manually.
- No secrets in the repo; mount SSH keys/tokens at runtime.

## Roadmap
- [ ] Implement real agent entry command (OpenClaw) + environment bootstrap.
- [ ] Flesh out supervisor IPC for `add/remove` commands.
- [ ] Handle SSH key injection (volume or secrets).
- [ ] Observability: structured logs, metrics, health endpoints.
- [ ] Windows/WSL guidance (CRLF vs LF).

## Status
Skeleton container works with dummy agents; log watcher script available. More wiring to come.
