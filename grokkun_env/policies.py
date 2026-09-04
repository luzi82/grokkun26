"""Hand-written policies for env sanity checks (not learned)."""

from __future__ import annotations

import math

from grokkun_env.env import ACTIONS, Grokkun26Env


def _dir_to_action(dx: float, dy: float) -> str:
    """Map a continuous flee/seek vector to the nearest 8-way (+ idle)."""
    if abs(dx) < 1e-6 and abs(dy) < 1e-6:
        return "idle"
    # Quantize to 8-way using signs of dominant axes.
    ax = 0 if abs(dx) < 0.4 * max(abs(dy), 1e-9) else (1 if dx > 0 else -1)
    ay = 0 if abs(dy) < 0.4 * max(abs(dx), 1e-9) else (1 if dy > 0 else -1)
    if ax == 0 and ay == 0:
        # nearly diagonal-equal or tiny — use full sign
        ax = 1 if dx > 0 else (-1 if dx < 0 else 0)
        ay = 1 if dy > 0 else (-1 if dy < 0 else 0)
    key = {
        (0, -1): "n",
        (1, -1): "ne",
        (1, 0): "e",
        (1, 1): "se",
        (0, 1): "s",
        (-1, 1): "sw",
        (-1, 0): "w",
        (-1, -1): "nw",
        (0, 0): "idle",
    }
    return key.get((ax, ay), "idle")


class IdlePolicy:
    """Always idle — baseline (should die sooner than flee)."""

    def act(self, env: Grokkun26Env) -> str:
        return "idle"


class FleeNearestBullet:
    """Move away from the nearest live bullet; idle if none."""

    def act(self, env: Grokkun26Env) -> str:
        if not env.bullets:
            return "idle"
        best = None
        best_d2 = float("inf")
        for b in env.bullets:
            d2 = (b.x - env.px) ** 2 + (b.y - env.py) ** 2
            if d2 < best_d2:
                best_d2 = d2
                best = b
        assert best is not None
        # Flee: opposite of vector from player to bullet.
        dx = env.px - best.x
        dy = env.py - best.y
        return _dir_to_action(dx, dy)


class SeekCenter:
    """Always walk toward field center (weak baseline)."""

    def act(self, env: Grokkun26Env) -> str:
        from grokkun_env import constants as C

        cx = C.FIELD_X + C.FIELD_W * 0.5
        cy = C.FIELD_Y + C.FIELD_H * 0.5
        return _dir_to_action(cx - env.px, cy - env.py)


POLICIES = {
    "idle": IdlePolicy,
    "flee": FleeNearestBullet,
    "center": SeekCenter,
}


def action_index(name: str) -> int:
    return ACTIONS.index(name)
