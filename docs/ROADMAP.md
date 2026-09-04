# Grokkun26 roadmap

0–1 **Playable core** — done  
Godot 4 dodge game, Windows/Linux export, mascot + look dirs, snap-stop, denser bullets.

3 **RL env** — in progress  
Pure-Python `grokkun_env` + monkey parity + rule sanity. CPU REINFORCE player MLP started (`grokkun_env/train_player.py`, ~7.7k params; beats idle, still below flee). Next: stronger train (PPO / GPU on 1650 or GB10) → train spawner → self-play.

2 **Playability polish** — after RL  
Feel/difficulty, optional SFX/BGM, replay/ghost.

4 **Later**  
Leaderboards / extra modes.
