# Dev container for chip-design-learning: every front-end tool from the course,
# preinstalled, so `make sim`, `make synth-sky130` and `make plot` work on the
# first try. The back end (OpenROAD + sky130) runs in Docker through the
# docker-in-docker feature in devcontainer.json, exactly as on a laptop.
FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

# Same Ubuntu 24.04 packages that CI uses (Yosys 0.33, Verilator 5.x),
# plus GTKWave and KLayout for the browser desktop, and OSMesa for the
# off-screen 3D renders.
RUN apt-get update \
 && export DEBIAN_FRONTEND=noninteractive \
 && apt-get install -y --no-install-recommends \
        iverilog verilator yosys gtkwave klayout graphviz make curl \
        python3 python3-venv python3-pip libosmesa6 \
 && rm -rf /var/lib/apt/lists/*

# Python packages go in a venv on PATH (Ubuntu 24.04 blocks system-wide pip).
COPY python/requirements.txt /tmp/requirements.txt
RUN python3 -m venv /opt/venv \
 && /opt/venv/bin/pip install --no-cache-dir -r /tmp/requirements.txt \
 && rm /tmp/requirements.txt \
 && chown -R vscode:vscode /opt/venv
ENV PATH=/opt/venv/bin:$PATH
