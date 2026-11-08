# cocotb test for the Tiny Tapeout FIR

`Makefile` and `tb.v` come from the Tiny Tapeout
[ttsky-verilog-template](https://github.com/TinyTapeout/ttsky-verilog-template)
(Apache-2.0), with `PROJECT_SOURCES` and the module name filled in.
`test.py` is this project's test: it drives the chip only through its pins
and checks every output against a bit-exact Python model.

```sh
pip install -r requirements.txt
make -B                 # RTL simulation (or `make tt-test` one level up)
make -B GATES=yes       # gate level: copy the hardened netlist to gate_level_netlist.v first
```

The template's GitHub Actions run both. See `../README.md` for submitting.
