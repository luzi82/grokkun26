#!/usr/bin/env python3
"""Replay a Godot monkey JSONL in Qrokkun26Env and report parity diffs."""

from __future__ import annotations

import argparse
import json
import math
import sys
from pathlib import Path

from qrokkun_env import ACTIONS, Qrokkun26Env
from qrokkun_env import constants as C


def load_log(path: Path) -> tuple[dict, list[dict]]:
    header = None
    frames: list[dict] = []
    for line in path.read_text().splitlines():
        if not line.strip():
            continue
        row = json.loads(line)
        if row.get("kind") == "header":
            header = row
        elif row.get("kind") == "frame":
            frames.append(row)
    if header is None:
        raise SystemExit(f"no header in {path}")
    return header, frames


def bullet_key(b: dict) -> tuple:
    return (
        round(b["x"], 3),
        round(b["y"], 3),
        round(b["vx"], 3),
        round(b["vy"], 3),
        int(b["kind"]),
    )


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("log", type=Path)
    ap.add_argument("--atol", type=float, default=0.05, help="position tolerance (px)")
    ap.add_argument("--max-frames", type=int, default=0)
    args = ap.parse_args()

    header, frames = load_log(args.log)
    seed = int(header["seed"])
    env = Qrokkun26Env(seed=seed)
    env.reset(seed=seed)

    # Godot frame 0 is the state AFTER the first physics tick with action idle
    # (or the first recorded action). Replay the same actions.
    mismatches = 0
    checked = 0
    limit = args.max_frames or len(frames)

    for i, fr in enumerate(frames[:limit]):
        action = fr["action"]
        if action not in ACTIONS:
            print(f"frame {i}: unknown action {action!r}")
            return 2
        obs, _reward, done, info = env.step(action)
        checked += 1

        px, py, pvx, pvy = (
            fr["player"]["x"],
            fr["player"]["y"],
            fr["player"]["vx"],
            fr["player"]["vy"],
        )
        errs = []
        if abs(env.px - px) > args.atol or abs(env.py - py) > args.atol:
            errs.append(
                f"player pos py=({env.px:.4f},{env.py:.4f}) gd=({px:.4f},{py:.4f})"
            )
        if abs(env.pvx - pvx) > args.atol or abs(env.pvy - pvy) > args.atol:
            errs.append(
                f"player vel py=({env.pvx:.4f},{env.pvy:.4f}) gd=({pvx:.4f},{pvy:.4f})"
            )
        if abs(env.elapsed - fr["elapsed"]) > 1e-4:
            errs.append(f"elapsed py={env.elapsed} gd={fr['elapsed']}")
        if abs(env.spawn_acc - fr["spawn_acc"]) > args.atol:
            errs.append(f"spawn_acc py={env.spawn_acc:.6f} gd={fr['spawn_acc']:.6f}")

        gd_bullets = fr["bullets"]
        if len(env.bullets) != len(gd_bullets):
            errs.append(f"bullet_count py={len(env.bullets)} gd={len(gd_bullets)}")
        else:
            # Match by sorting both on position (order may differ).
            py_b = sorted(
                [
                    {
                        "x": b.x,
                        "y": b.y,
                        "vx": b.vx,
                        "vy": b.vy,
                        "kind": b.kind,
                        "r": b.radius,
                    }
                    for b in env.bullets
                ],
                key=bullet_key,
            )
            gd_b = sorted(gd_bullets, key=bullet_key)
            for a, b in zip(py_b, gd_b):
                if (
                    abs(a["x"] - b["x"]) > args.atol
                    or abs(a["y"] - b["y"]) > args.atol
                    or abs(a["vx"] - b["vx"]) > args.atol
                    or abs(a["vy"] - b["vy"]) > args.atol
                    or a["kind"] != b["kind"]
                ):
                    errs.append(f"bullet py={a} gd={b}")
                    break

        if bool(fr["dead"]) != bool(env.dead):
            errs.append(f"dead py={env.dead} gd={fr['dead']}")

        if errs:
            mismatches += 1
            print(f"FAIL frame {fr['frame']} action={action}:")
            for e in errs[:6]:
                print(f"  {e}")
            if mismatches >= 8:
                print("… stopping after 8 mismatch frames")
                break

    print(
        f"checked={checked} mismatches={mismatches} "
        f"seed={seed} atol={args.atol} log={args.log}"
    )
    return 1 if mismatches else 0


if __name__ == "__main__":
    sys.exit(main())
