# Agent Smith base image
# Provides a minimal environment for running multiple OpenClaw-like agents in isolation.

FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=UTC \
    AGENT_COUNT=4

# Install OS packages (curl/git/python/etc.)
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    git \
    openssh-client \
    python3 \
    python3-pip \
    tmux \
    sudo \
    jq \
    && rm -rf /var/lib/apt/lists/*

# Add non-root user for running agents
RUN useradd -ms /bin/bash agent && echo "agent ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
USER agent
WORKDIR /home/agent

# Copy supervisor + scripts into image
COPY --chown=agent:agent supervisor /agent_smith/supervisor
COPY --chown=agent:agent scripts /agent_smith/scripts
COPY --chown=agent:agent docker/entrypoint.sh /agent_smith/entrypoint.sh

# Workspace mount point (bind mount from host)
RUN mkdir -p /agents/workspace
VOLUME /agents/workspace

# Install Python deps for supervisor (none yet, placeholder)
RUN pip3 install --user --no-cache-dir pyyaml

ENTRYPOINT ["/agent_smith/entrypoint.sh"]
