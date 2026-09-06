"""GodotRNG must match Godot 4 RandomNumberGenerator seed=42 probe."""

from qrokkun_env.godot_rng import GodotRNG


def test_state_after_seed_42():
    rng = GodotRNG(42)
    assert rng.state == 708718527385777908


def test_randi_range_matches_godot_probe():
    rng = GodotRNG(42)
    assert [rng.randi_range(0, 3) for _ in range(8)] == [1, 0, 0, 3, 0, 0, 2, 3]


def test_randf_matches_godot_probe():
    rng = GodotRNG(42)
    expected = [
        0.11837019026279,
        0.65903240442276,
        0.29818680882454,
        0.03759671002626,
        0.75990653038025,
    ]
    for e in expected:
        assert abs(rng.randf() - e) < 1e-12
