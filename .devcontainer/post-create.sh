#!/usr/bin/env bash
# Runs once when the codespace is created.
set -uo pipefail
cd "$(dirname "$0")/.."

echo "== Tools in this codespace =="
make -s doctor

# sky130 standard-cell Liberty file for `make synth-sky130` (cached in .cache/)
make -s -C designs/counter "$PWD/.cache/sky130_fd_sc_hd__tt_025C_1v80.lib" >/dev/null 2>&1 \
    || echo "Could not fetch the sky130 Liberty file yet; make synth-sky130 will retry."

cat <<'MSG'

Ready. Try:
  make sim                 # counter testbench, prints PASS
  make synth-sky130        # map onto real sky130 cells
  make pnr                 # RTL to GDS with OpenROAD (first run pulls a large image)
  make sim plot DESIGN=fir # FIR filter waveforms and frequency response

Desktop for GTKWave / KLayout / OpenROAD GUI: Ports tab -> 6080 -> open in browser
(password: vscode). Guide: docs/codespaces.md
MSG
