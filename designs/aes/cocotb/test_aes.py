"""test_aes.py -- cocotb testbench for the private-link chip rtl/aes_ctr.v

The golden model is python/aes_model.py, a step-by-step AES-128 in plain
Python. Three ideas from the verification module, used on a crypto block:

1. **Known answers first.** A crypto core that is "almost right" gives
   garbage, so start from the published test vectors (FIPS-197, SP 800-38A).
2. **A reference model for everything else**: random keys, counters and
   messages, checked byte for byte against the Python model.
3. **Drive the interface the way a real system would**: random gaps between
   bytes and a key change in the middle of a block.

Run:  make cocotb            (in designs/aes)
"""
import random

import cocotb
from cocotb.triggers import ClockCycles, FallingEdge, ReadOnly, RisingEdge

import aes_model
from cocotb_util import start


class Link:
    """Drives one aes_ctr chip and collects every byte it puts out."""

    def __init__(self, dut):
        self.dut = dut
        self.out = []
        dut.in_data.value = 0
        dut.key_we.value = 0
        dut.iv_we.value = 0
        dut.in_valid.value = 0
        cocotb.start_soon(self._monitor())

    async def _monitor(self):
        while True:
            await RisingEdge(self.dut.clk)
            await ReadOnly()
            if self.dut.out_valid.value == 1:
                self.out.append(int(self.dut.out_data.value))

    async def load(self, value, strobe):
        """Shift a 128-bit key or counter block in, most significant byte first.
        Call it on a falling edge, like every other input change."""
        for b in value.to_bytes(16, "big"):
            self.dut.in_data.value = b
            strobe.value = 1
            await FallingEdge(self.dut.clk)
        strobe.value = 0

    async def setup(self, key, iv):
        await FallingEdge(self.dut.clk)
        await self.load(key, self.dut.key_we)
        await self.load(iv, self.dut.iv_we)

    async def send(self, data, gap=0.0):
        """Send bytes; with gap > 0, idle clocks are put in at random."""
        for b in data:
            while random.random() < gap:
                await FallingEdge(self.dut.clk)
            self.dut.in_data.value = b
            self.dut.in_valid.value = 1
            while True:
                await RisingEdge(self.dut.clk)
                taken = self.dut.in_ready.value == 1
                await FallingEdge(self.dut.clk)
                if taken:
                    break
            self.dut.in_valid.value = 0

    async def run(self, key, iv, data, gap=0.0):
        self.out.clear()
        await self.setup(key, iv)
        await self.send(data, gap)
        await ClockCycles(self.dut.clk, 2)
        return bytes(self.out)


@cocotb.test()
async def test_fips197(dut):
    """FIPS-197 vectors through the chip: counter = plaintext, data = zeros.

    The first keystream block is AES_K(counter), so sending 16 zero bytes
    reads out the ciphertext of the counter block directly.
    """
    await start(dut)
    link = Link(dut)
    vectors = aes_model.FIPS197 + list(zip([aes_model.SP800_KEY] * 4,
                                           aes_model.SP800_PT, aes_model.SP800_ECB))
    for key, pt, ct in vectors:
        got = await link.run(key, pt, bytes(16))
        assert got == ct.to_bytes(16, "big"), f"key {key:032x}: got {got.hex()}, expected {ct:032x}"


@cocotb.test()
async def test_sp800_38a_ctr(dut):
    """NIST SP 800-38A F.5.1 (CTR-AES128): encrypt, then decrypt with the same chip."""
    await start(dut)
    link = Link(dut)
    pt = b"".join(p.to_bytes(16, "big") for p in aes_model.SP800_PT)
    ct = b"".join(c.to_bytes(16, "big") for c in aes_model.SP800_CTR)
    assert await link.run(aes_model.SP800_KEY, aes_model.SP800_CTR_IV, pt) == ct
    assert await link.run(aes_model.SP800_KEY, aes_model.SP800_CTR_IV, ct) == pt


@cocotb.test()
async def test_random_messages(dut):
    """Random keys, counters (including the 32-bit wrap) and message lengths."""
    await start(dut)
    link = Link(dut)
    for n in range(12):
        key = random.getrandbits(128)
        iv = random.getrandbits(128)
        if n == 0:
            iv |= 0xFFFFFFFE          # the low 32 bits wrap after two blocks
        msg = random.randbytes(random.randint(1, 70))
        got = await link.run(key, iv, msg, gap=0.3 if n % 2 else 0.0)
        assert got == aes_model.ctr(key, iv, msg), f"message {n}, {len(msg)} bytes"


@cocotb.test()
async def test_rekey_mid_block(dut):
    """A new key and counter in the middle of a block, and while the core runs,
    must restart the keystream from the new counter: no old bytes leak out."""
    await start(dut)
    link = Link(dut)
    k1, iv1 = random.getrandbits(128), random.getrandbits(128)
    k2, iv2 = random.getrandbits(128), random.getrandbits(128)
    await link.setup(k1, iv1)
    await link.send(bytes(5))
    # Change the key while the core is (or soon will be) busy
    await link.setup(k2, iv2)
    link.out.clear()
    msg = random.randbytes(40)
    await link.send(msg)
    await ClockCycles(dut.clk, 2)
    assert bytes(link.out) == aes_model.ctr(k2, iv2, msg)

    # The same, but the counter is reloaded 3 clocks after the key: the core
    # starts a block with the new key and the old counter, which must be dropped
    await FallingEdge(dut.clk)          # drive inputs half a clock from the edge
    await link.load(k1, dut.key_we)
    await ClockCycles(dut.clk, 3)
    await FallingEdge(dut.clk)
    await link.load(iv1, dut.iv_we)
    link.out.clear()
    await link.send(msg)
    await ClockCycles(dut.clk, 2)
    assert bytes(link.out) == aes_model.ctr(k1, iv1, msg)

    # A short write while the core is busy: after 16 bytes the core starts the
    # next block; 4 counter bytes written while it runs must make the chip
    # drop that block when it finishes, after the write has ended.
    await FallingEdge(dut.clk)
    await link.setup(k1, iv1)
    await link.send(bytes(16))
    await FallingEdge(dut.clk)                 # the core starts on this edge
    assert dut.u_core.busy.value == 1
    word = random.getrandbits(32)
    for b in word.to_bytes(4, "big"):
        dut.in_data.value = b
        dut.iv_we.value = 1
        await FallingEdge(dut.clk)
    dut.iv_we.value = 0
    ctr_now = (iv1 & ~0xFFFFFFFF) | ((iv1 + 1) & 0xFFFFFFFF)   # one block was used
    ctr_new = ((ctr_now << 32) | word) & ((1 << 128) - 1)      # the counter is a shift register
    link.out.clear()
    await link.send(msg)
    await ClockCycles(dut.clk, 2)
    assert bytes(link.out) == aes_model.ctr(k1, ctr_new, msg)


@cocotb.test()
async def test_alice_bob(dut):
    """The private link: what goes over the wire decrypts back with the key,
    and looks like noise without it."""
    await start(dut)
    link = Link(dut)
    key, iv = 0x436869702D636F757273652D6B657921, 0x6C696E6B2D6E6F6E63652D0000000000
    msg = b"Meet me in the lab at 9. Hardware is the new Software. Bring GDS"
    wire = await link.run(key, iv, msg)
    assert await link.run(key, iv, wire) == msg
    eve = await link.run(key ^ 1, iv, wire)      # one bit of the key wrong
    same = sum(a == b for a, b in zip(eve, msg))
    dut._log.info("wire: %s...", wire[:16].hex(" "))
    dut._log.info("Eve with one key bit flipped matches %d of %d bytes", same, len(msg))
    assert same < 8, "a one-bit key error should give unrelated bytes"
