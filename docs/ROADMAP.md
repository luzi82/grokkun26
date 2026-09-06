# Qrokkun26 roadmap

0–1 **Playable core** — done  
Godot 4 dodge game, Windows/Linux export, mascot + look dirs, snap-stop, denser bullets.

3 **RL env** — in progress  
Pure-Python `qrokkun_env` + monkey parity + rule sanity. CPU actor-critic long run done (~23.7k params, ~2.75h, best eval ~14.2s vs flee ~16.7s — beats idle, did not beat flee). Next: GPU train on GB10 via grokbot-2609a → train spawner → self-play.

2 **Playability polish** — after RL  
Feel/difficulty, optional SFX/BGM, replay/ghost.

4 **Later**  
Leaderboards / extra modes.
