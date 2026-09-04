"""Fixed-rule bot sanity: env runs end-to-end; flee beats idle on average."""

from __future__ import annotations

from grokkun_env.policies import FleeNearestBullet, IdlePolicy, _dir_to_action
from grokkun_env.sanity import run_episode, summarize


def test_dir_to_action_cardinals():
    assert _dir_to_action(0, -1) == "n"
    assert _dir_to_action(1, 0) == "e"
    assert _dir_to_action(0, 0) == "idle"


def test_idle_episode_terminates():
    r = run_episode("idle", seed=0, max_steps=60 * 120)
    assert r.dead is True
    assert r.elapsed > 0.5  # survives the spawn warmup a bit


def test_flee_episode_runs():
    r = run_episode("flee", seed=1, max_steps=60 * 120)
    assert r.steps >= 1
    assert r.elapsed > 0.0


def test_flee_outlasts_idle_on_average():
    """Sanity: flee-nearest should beat idle across a small seed sweep."""
    n = 12
    idle = [run_episode("idle", seed=s) for s in range(n)]
    flee = [run_episode("flee", seed=s) for s in range(n)]
    idle_m = summarize("idle", idle)["mean"]
    flee_m = summarize("flee", flee)["mean"]
    assert flee_m > idle_m, (flee_m, idle_m)
