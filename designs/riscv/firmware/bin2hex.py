#!/usr/bin/env python3
"""bin2hex.py -- turn a raw binary into one 32-bit little-endian word per line.

The output is what Verilog's $readmemh expects for a 32-bit wide memory:

    python3 bin2hex.py hello.bin hello.hex
"""
import sys

data = open(sys.argv[1], "rb").read()
data += bytes(-len(data) % 4)
with open(sys.argv[2], "w") as f:
    f.write("@00000000\n")              # load address (word 0)
    for i in range(0, len(data), 4):
        f.write("%08x\n" % int.from_bytes(data[i:i + 4], "little"))
