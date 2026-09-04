"""Smoke tests for Grokkun26Env."""

from __future__ import annotations

import math

from grokkun_env import ACTIONS, Grokkun26Env
from grokkun_env import constants as C
from grokkun_env.env import _move_toward, _spawn_interval


def test_actions_count():
    assert len(ACTIONS) == 9


def test_reset_centers_player():
    env = Grokkun26Env(seed=1)
    obs = env.reset()
    assert abs(obs["player"][0] - (C.FIELD_X + C.FIELD_W * 0.5)) < 1e-6
    assert abs(obs["player"][1] - (C.FIELD_Y + C.FIELD_H * 0.5)) < 1e-6
    assert obs["dead"] is False
    assert obs["elapsed"] == 0.0


def test_idle_snap_stop():
    env = Grokkun26Env(seed=2)
    env.reset()
    env.step("e")
    assert env.pvx != 0.0 or env.pvy != 0.0
    env.step("idle")
    assert env.pvx == 0.0 and env.pvy == 0.0


def test_move_toward_godot_parity():
    x, y = _move_toward(0.0, 0.0, 10.0, 0.0, 3.0)
    assert abs(x - 3.0) < 1e-9 and abs(y) < 1e-9
    x, y = _move_toward(0.0, 0.0, 2.0, 0.0, 3.0)
    assert abs(x - 2.0) < 1e-9


def test_spawn_interval_decreases():
    assert _spawn_interval(0.0) > _spawn_interval(30.0) > _spawn_interval(90.0)


def test_seeded_run_is_deterministic():
    def run(seed: int) -> list[float]:
        env = Grokkun26Env(seed=seed)
        env.reset(seed=seed)
        times = []
        for i in range(180):
            action = ACTIONS[i % len(ACTIONS)]
            obs, reward, done, info = env.step(action)
            times.append(info["elapsed"])
            if done:
                break
        return times

    assert run(42) == run(42)


def test_hit_terminates():
    env = Grokkun26Env(seed=0)
    env.reset()
    # Force a bullet on top of the player.
    from grokkun_env.env import Bullet

    env.bullets = [Bullet(env.px, env.py, 0.0, 0.0, 0, 2.0)]
    obs, reward, done, info = env.step("idle")
    assert done is True
    assert env.dead is True
    assert reward == C.DT


def test_survives_a_few_seconds_moving():
    env = Grokkun26Env(seed=7)
    env.reset(seed=7)
    done = False
    for _ in range(120):  # 2 seconds
        obs, reward, done, info = env.step("n")
        if done:
            break
    # Not asserting survival — only that API stays healthy.
    assert "elapsed" in info
    assert math.isfinite(obs["player"][0])


def test_observation_padding_is_not_a_fake_bullet():
    """Empty / padded bullet slots must not look like a live bullet at (0,0).

    observe() currently zero-fills the flat bullet vector, so an empty field
    reads as 32 bullets at the origin with radius 0 — bad for a small MLP.
    Prefer a mask channel, or a sentinel (e.g. radius < 0) on padded slots.
    """
    env = Grokkun26Env(seed=0)
    env.reset()
    env.bullets.clear()
    obs = env.observe()
    assert obs["bullet_count"] == 0
    if "bullet_mask" in obs:
        assert sum(obs["bullet_mask"]) == 0
        return
    # No mask: every padded slot's radius (index 4 in each 6-float record) must
    # be a sentinel, not a real non-negative hit radius.
    for i in range(0, len(obs["bullets"]), 6):
        radius = obs["bullets"][i + 4]
        assert radius < 0.0, (i, obs["bullets"][i : i + 6])
