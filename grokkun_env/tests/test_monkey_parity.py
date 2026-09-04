"""Godot monkey recording must replay bit-close in Grokkun26Env."""

from __future__ import annotations

import json
from pathlib import Path

from grokkun_env import ACTIONS, Grokkun26Env

FIX = Path(__file__).parent / "fixtures" / "monkey_seed42_120.jsonl"
ATOL = 0.05


def test_monkey_seed42_fixture_parity():
    rows = [json.loads(l) for l in FIX.read_text().splitlines() if l.strip()]
    header = next(r for r in rows if r["kind"] == "header")
    frames = [r for r in rows if r["kind"] == "frame"]
    env = Grokkun26Env(seed=int(header["seed"]))
    env.reset(seed=int(header["seed"]))
    for fr in frames:
        assert fr["action"] in ACTIONS
        env.step(fr["action"])
        assert abs(env.px - fr["player"]["x"]) <= ATOL
        assert abs(env.py - fr["player"]["y"]) <= ATOL
        assert abs(env.pvx - fr["player"]["vx"]) <= ATOL
        assert abs(env.pvy - fr["player"]["vy"]) <= ATOL
        assert len(env.bullets) == len(fr["bullets"])
        assert bool(env.dead) == bool(fr["dead"])


def test_monkey_fixture_covers_at_least_one_bullet():
    """CI fixture must include a spawn, not only the empty pre-spawn warmup.

    seed=42 first bullet appears around frame 69; a 60-frame trim never
    exercises bullet integrate / new-bullet same-frame skip / aim RNG.
    """
    rows = [json.loads(l) for l in FIX.read_text().splitlines() if l.strip()]
    frames = [r for r in rows if r["kind"] == "frame"]
    assert any(len(fr["bullets"]) > 0 for fr in frames), (
        f"fixture has {len(frames)} frames but never a bullet"
    )


def test_monkey_fixture_checks_bullet_pose():
    """When bullets exist, replay must match positions (not only counts)."""
    rows = [json.loads(l) for l in FIX.read_text().splitlines() if l.strip()]
    header = next(r for r in rows if r["kind"] == "header")
    frames = [r for r in rows if r["kind"] == "frame"]
    env = Grokkun26Env(seed=int(header["seed"]))
    env.reset(seed=int(header["seed"]))
    saw = False
    for fr in frames:
        env.step(fr["action"])
        if not fr["bullets"]:
            continue
        saw = True
        assert len(env.bullets) == len(fr["bullets"])
        py_b = sorted([(b.x, b.y, b.vx, b.vy, b.kind) for b in env.bullets])
        gd_b = sorted(
            [(b["x"], b["y"], b["vx"], b["vy"], int(b["kind"])) for b in fr["bullets"]]
        )
        for a, b in zip(py_b, gd_b):
            assert abs(a[0] - b[0]) <= ATOL and abs(a[1] - b[1]) <= ATOL
            assert abs(a[2] - b[2]) <= ATOL and abs(a[3] - b[3]) <= ATOL
            assert a[4] == b[4]
    assert saw, "fixture never a bullet — extend past first spawn"
