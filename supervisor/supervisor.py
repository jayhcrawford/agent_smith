#!/usr/bin/env python3
"""Lightweight process supervisor for Agent Smith.

Responsibilities:
- Spawn N agent processes (default via --agent-count)
- Manage per-agent workspace directories
- Respond to runtime signals (add/remove) initiated via scripts
This is an early stub; wiring into real agent binaries happens later.
"""

from __future__ import annotations

import argparse
import os
import subprocess
import sys
from pathlib import Path
import yaml


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Agent Smith supervisor")
    parser.add_argument("--config", default="/agent_smith/supervisor/config.yaml")
    parser.add_argument("--agent-count", type=int, default=4)
    parser.add_argument("--signal", choices=["add", "remove"], default=None)
    parser.add_argument("--count", type=int, default=1,
                        help="Used with --signal to add/remove agents")
    return parser.parse_args()


def load_config(path: str) -> dict:
    with open(path, "r", encoding="utf-8") as fh:
        return yaml.safe_load(fh) or {}


def ensure_workspace(root: Path, agent_id: int) -> Path:
    agent_dir = root / f"agent-{agent_id}"
    agent_dir.mkdir(parents=True, exist_ok=True)
    return agent_dir


def start_agent(agent_dir: Path, cfg: dict) -> subprocess.Popen:
    # Placeholder command. Later this should invoke OpenClaw / custom agent runner.
    cmd = cfg.get("agent_binary", "bash")
    args = cfg.get("agent_args", [])
    env = {**cfg.get("default_environment", {}), **dict(os.environ)}

    return subprocess.Popen(
        [cmd, *args],
        cwd=agent_dir,
        env=env,
    )


def main() -> None:
    args = parse_args()
    cfg = load_config(args.config)

    workspace_root = Path(cfg.get("workspace_root", "/agents/workspace"))
    workspace_root.mkdir(parents=True, exist_ok=True)

    if args.signal:
        print(f"[supervisor] Received signal {args.signal} count={args.count}")
        # TODO: implement IPC/state tracking for add/remove requests
        return

    agent_processes = []
    for idx in range(1, args.agent_count + 1):
        agent_dir = ensure_workspace(workspace_root, idx)
        proc = start_agent(agent_dir, cfg)
        agent_processes.append(proc)
        print(f"[supervisor] Spawned agent-{idx} (pid {proc.pid})")

    # Wait for child processes (placeholder: wait on first)
    for proc in agent_processes:
        proc.wait()


if __name__ == "__main__":
    try:
        main()
    except Exception as exc:  # noqa: BLE001
        print(f"[supervisor] Fatal error: {exc}", file=sys.stderr)
        sys.exit(1)
