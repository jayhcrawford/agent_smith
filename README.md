# Agent Smith

Agent Smith is an A→Z toolkit for launching an isolated Docker container that can host multiple OpenClaw‑style agents at once. Each agent gets its own workspace inside the container, keeping the host machine clean while still allowing access to GitHub repositories via SSH or other auth methods.

## Goals
- **Isolation:** Agents run inside a containerized environment separate from the host file system.
- **Parallelism:** Spin up N agents (default 4) without juggling multiple VMs/containers.
- **Safety:** No agent has unilateral authority to modify multiple repos at once; cross‑repo work requires explicit human coordination.
- **Clarity:** Code and docs should be simple enough for humans to audit quickly (low token burn).

## High-Level Concept
1. **Docker image builds** the base environment (Debian/Ubuntu + dev tooling + OpenClaw dependencies).
2. **Entry script** boots a supervisor that spawns the configured number of agents (default `AGENT_COUNT=4`).
3. Each agent gets:
   - A dedicated workspace directory (e.g., `/agents/agent-1`).
   - SSH access (keys mounted or injected) for cloning GitHub repos.
   - Resource limits to prevent runaway processes.
4. **Scaling**: CLI/API to add/remove agents on the fly without rebuilding or restarting the entire container.
5. **Policy enforcement**: For tasks spanning multiple repos, agents must hand off to the coordinator (prevents conflicting commits and simplifies auditing).

## Repo Layout (in progress)
```
agent_smith/
├─ docker/
│  ├─ Dockerfile              # Builds the container image
│  ├─ entrypoint.sh           # Boots supervisor + agents
├─ scripts/
│  ├─ start_agents.sh         # CLI wrapper for spinning up N agents
│  ├─ add_agent.sh            # Adds a new agent instance at runtime
│  ├─ remove_agent.sh         # Gracefully stops an agent
├─ supervisor/
│  ├─ config.yaml             # Agent definitions, resource caps
│  ├─ supervisor.py           # Spawns/monitors individual agent processes
├─ workspace/
│  └─ (created at runtime)    # Per-agent dirs mounted from host volume
├─ README.md
└─ TODO.md (or ROADMAP.md)
```
> **Note:** directory names are placeholders; flesh them out as implementation lands.

## Runtime Flow
1. `docker run -e AGENT_COUNT=4 agent_smith` → entrypoint boots supervisor.
2. Supervisor spawns 4 agent processes, each launching OpenClaw (or another LLM agent framework) in its workspace.
3. Agent clones `git@github.com:Org/repo.git` via mounted SSH key and executes the assigned tasks.
4. Logs + artifacts stay inside the container unless explicitly exported/mounted.
5. To add an agent: `docker exec agent_smith add_agent.sh` (increments count, allocates workspace).

## Constraints / Policies
- **One repo per agent**: simplifies troubleshooting and avoids merge conflicts.
- **No cross-repo writes without coordinator approval**: if an agent needs changes in two repos, it must escalate.
- **Human-auditable**: maintain `README`, `ROADMAP`, and `RISKS` docs so future contributors can reason quickly.

## Roadmap
- [ ] Draft detailed Dockerfile + base image.
- [ ] Implement supervisor (process manager + health checks).
- [ ] CLI for scaling agents up/down.
- [ ] Workspace volume strategy (bind mount vs. named volumes).
- [ ] Access control for SSH keys / GitHub tokens.
- [ ] Observability (per-agent logs + metrics export).

## Usage (future)
```bash
# Build image
cd docker
./build.sh

# Run with default 4 agents
./scripts/start_agents.sh

# Add another agent on the fly
./scripts/add_agent.sh
```

## Status
Early concept stage. README captures intent, constraints, and rough layout so we can start stubbing in Docker + supervisor code next.

## Testing the Skeleton
Until real agents are wired up, the container launches the dummy script `scripts/dummy_agent.sh`.
It writes heartbeats to `workspace/agent-*/agent.log`. Build + run:
```bash
./scripts/start_agents.sh
```
Adjust `AGENT_COUNT` env var to scale. Add/remove scripts are stubbed; supervisor will log signals once IPC is implemented.

## Watching Logs
Inside the running container you can open a tmux session that tails every agent log:
```bash
docker exec -it agent-smith /agent_smith/scripts/watch_logs.sh
```
If a session already exists, the script just attaches. Exit tmux (Ctrl+b d) to detach.
