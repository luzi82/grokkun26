"""Observation vectorizer."""

from grokkun_env.env import Grokkun26Env
from grokkun_env.obs import OBS_DIM, vectorize


def test_obs_dim():
    env = Grokkun26Env(seed=0)
    env.reset(seed=0)
    assert len(vectorize(env)) == OBS_DIM
