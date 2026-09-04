#!/usr/bin/env python3
"""Fixed-rule bot vs scripted spawner — env sanity check (no learning)."""

from __future__ import annotations

import argparse
import statistics
from dataclasses import dataclass

from grokkun_env.env import Grokkun26Env
from grokkun_env.policies import POLICIES


@dataclass
class EpisodeResult:
    seed: int
    elapsed: float
    steps: int
    dead: bool


def run_episode(policy_name: str, seed: int, max_steps: int = 60 * 90) -> EpisodeResult:
    """One game: rule player vs built-in scripted spawner."""
    policy = POLICIES[policy_name]()
    env = Grokkun26Env(seed=seed)
    env.reset(seed=seed)
    steps = 0
    for steps in range(1, max_steps + 1):
        action = policy.act(env)
        _obs, _reward, done, info = env.step(action)
        if done:
            return EpisodeResult(seed=seed, elapsed=float(info["elapsed"]), steps=steps, dead=True)
    return EpisodeResult(seed=seed, elapsed=env.elapsed, steps=steps, dead=env.dead)


def summarize(name: str, results: list[EpisodeResult]) -> dict:
    times = [r.elapsed for r in results]
    return {
        "policy": name,
        "n": len(results),
        "mean": statistics.mean(times),
        "median": statistics.median(times),
        "min": min(times),
        "max": max(times),
        "stdev": statistics.pstdev(times) if len(times) > 1 else 0.0,
    }


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--policy", choices=sorted(POLICIES), default="flee")
    ap.add_argument("--seeds", type=int, default=20, help="seeds 0..N-1")
    ap.add_argument("--compare", action="store_true", help="also run idle baseline")
    ap.add_argument("--max-steps", type=int, default=60 * 90)
    args = ap.parse_args()

    names = [args.policy]
    if args.compare and "idle" not in names:
        names.append("idle")

    for name in names:
        results = [run_episode(name, seed=s, max_steps=args.max_steps) for s in range(args.seeds)]
        s = summarize(name, results)
        print(
            f"{s['policy']}: n={s['n']} mean={s['mean']:.2f}s "
            f"median={s['median']:.2f}s min={s['min']:.2f}s max={s['max']:.2f}s "
            f"stdev={s['stdev']:.2f}"
        )


if __name__ == "__main__":
    main()
