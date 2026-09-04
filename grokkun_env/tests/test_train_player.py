"""Smoke tests for player MLP training pieces (no long train)."""

from __future__ import annotations

import pytest

torch = pytest.importorskip("torch")

from grokkun_env.env import ACTIONS, Grokkun26Env
from grokkun_env.train_player import PlayerMLP, collect_episode, discount_returns


def test_policy_forward_and_one_episode():
    torch.manual_seed(0)
    policy = PlayerMLP(hidden=32)
    env = Grokkun26Env(seed=1)
    env.reset(seed=1)
    rollout = collect_episode(env, policy, max_steps=30)
    assert len(rollout.rewards) >= 1
    assert len(rollout.log_probs) == len(rollout.rewards)
    G = discount_returns(rollout.rewards, 0.99)
    assert len(G) == len(rollout.rewards)
    loss = torch.stack([-lp * g for lp, g in zip(rollout.log_probs, G)]).sum()
    loss.backward()
    assert policy.net[0].weight.grad is not None
    assert policy.net[-1].out_features == len(ACTIONS)
