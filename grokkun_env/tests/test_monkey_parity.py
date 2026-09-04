"""Godot monkey recording must replay bit-close in Grokkun26Env."""

from __future__ import annotations

import json
from pathlib import Path

from grokkun_env import ACTIONS, Grokkun26Env

FIX = Path(__file__).parent / "fixtures" / "monkey_seed42_60.jsonl"
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
