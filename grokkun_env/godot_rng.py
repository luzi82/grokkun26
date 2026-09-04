"""Godot 4 RandomNumberGenerator (PCG32) port for parity tests."""

from __future__ import annotations

import math
import struct

PCG_DEFAULT_INC_64 = 1442695040888963407


def f32(x: float) -> float:
    return struct.unpack("f", struct.pack("f", float(x)))[0]


class GodotRNG:
    """Matches Godot 4.x RandomNumberGenerator seed/randf/randf_range/randi_range."""

    def __init__(self, seed: int = 0) -> None:
        self.current_inc = PCG_DEFAULT_INC_64
        self.current_seed = 0
        self.state = 0
        self.inc = 0
        self.seed(seed)

    def seed(self, initstate: int) -> None:
        self.current_seed = initstate & 0xFFFFFFFFFFFFFFFF
        self._srandom(self.current_seed, self.current_inc)

    def _srandom(self, initstate: int, initseq: int) -> None:
        self.state = 0
        self.inc = ((initseq << 1) | 1) & 0xFFFFFFFFFFFFFFFF
        self._rand()
        self.state = (self.state + initstate) & 0xFFFFFFFFFFFFFFFF
        self._rand()

    def _rand(self) -> int:
        oldstate = self.state
        self.state = (oldstate * 6364136223846793005 + (self.inc | 1)) & 0xFFFFFFFFFFFFFFFF
        xorshifted = (((oldstate >> 18) ^ oldstate) >> 27) & 0xFFFFFFFF
        rot = (oldstate >> 59) & 0xFFFFFFFF
        return ((xorshifted >> rot) | ((xorshifted << ((-rot) & 31)) & 0xFFFFFFFF)) & 0xFFFFFFFF

    def _bounded(self, bound: int) -> int:
        bound &= 0xFFFFFFFF
        threshold = (-bound) % bound
        while True:
            r = self._rand()
            if r >= threshold:
                return r % bound

    def random(self) -> float:
        """Alias for Python random.Random compatibility (unused)."""
        return self.randf()

    def randf(self) -> float:
        proto = self._rand()
        if proto == 0:
            return 0.0
        clz = 32 - proto.bit_length()
        significand = self._rand() | 0x80000001
        return f32(math.ldexp(f32(float(significand)), -32 - clz))

    def randf_range(self, a: float, b: float) -> float:
        return f32(self.randf() * f32(b - a) + f32(a))

    def randi_range(self, a: int, b: int) -> int:
        if a == b:
            return a
        mn, mx = (a, b) if a < b else (b, a)
        return self._bounded(mx - mn + 1) + mn

    # --- duck-type the bits env currently uses via random.Random ---
    def randrange(self, a: int, b: int | None = None) -> int:
        if b is None:
            return self.randi_range(0, a - 1)
        return self.randi_range(a, b - 1)

    def uniform(self, a: float, b: float) -> float:
        return self.randf_range(a, b)
