#!/usr/bin/env bash
# orfs.sh -- run OpenROAD-flow-scripts inside its official Docker image.
#
# Usage: scripts/orfs.sh <image> <design config.mk, relative to repo root> [make targets...]
#   scripts/orfs.sh openroad/orfs:latest designs/counter/orfs/config.mk
#   scripts/orfs.sh openroad/orfs:latest designs/counter/orfs/config.mk gui_final
#
# The repo is mounted at /work. Outputs go to <design>/build/orfs/ on the host:
#   logs/     per-step tool logs
#   reports/  timing, area, power, DRC reports
#   results/  netlists, DEF/ODB databases and the final GDS (6_final.gds)
set -euo pipefail

if [[ $# -lt 2 ]]; then
    sed -n '2,12p' "$0"
    exit 1
fi

image=$1
config=$2
shift 2

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
design_dir=$(dirname "$(dirname "$config")")
work_home=/work/$design_dir/build/orfs

docker_args=(--rm -v "$repo_root:/work")

# Use a TTY when we have one, and forward X11 for the GUI targets
if [[ -t 0 ]]; then docker_args+=(-it); fi
if [[ "$*" == *gui* ]]; then
    docker_args+=(-e "DISPLAY=${DISPLAY:-:0}" -v /tmp/.X11-unix:/tmp/.X11-unix --network host)
fi

docker run "${docker_args[@]}" "$image" bash -c "
    set -e
    cd /OpenROAD-flow-scripts
    source ./env.sh > /dev/null
    cd flow
    make DESIGN_CONFIG=/work/$config WORK_HOME=$work_home $*
    # Files created in the container are owned by root; hand them back.
    chown -R $(id -u):$(id -g) $work_home
"
