extends Node
## Appended by main in GROKKUN_MONKEY mode. Runs after siblings; writes JSONL.

var out_path: String = ""
var file: FileAccess
var frame: int = 0
var max_frames: int = 300
var actions: PackedStringArray = PackedStringArray([
	"idle", "n", "ne", "e", "se", "s", "sw", "w", "nw"
])
var dirs: Array = [
	Vector2.ZERO,
	Vector2(0, -1), Vector2(1, -1), Vector2(1, 0), Vector2(1, 1),
	Vector2(0, 1), Vector2(-1, 1), Vector2(-1, 0), Vector2(-1, -1),
]
var monkey_rng := RandomNumberGenerator.new()
var pending_action: String = "idle"
var main: Node2D
var started: bool = false


func setup(p_main: Node2D, seed: int, path: String, frames: int) -> void:
	main = p_main
	out_path = path
	max_frames = frames
	monkey_rng.seed = seed + 1
	file = FileAccess.open(out_path, FileAccess.WRITE)
	if file == null:
		push_error("monkey: cannot open " + out_path)
		return
	var header := {
		"kind": "header",
		"seed": seed,
		"action_seed": seed + 1,
		"dt": 1.0 / 60.0,
		"max_frames": max_frames,
	}
	file.store_line(JSON.stringify(header))
	file.flush()
	# Process after other nodes under Main (player + bullets).
	process_physics_priority = 100


func _physics_process(_delta: float) -> void:
	if file == null or main == null:
		return
	if not started:
		return
	if main.state != main.State.PLAYING and main.state != main.State.GAMEOVER:
		return

	# Record state AFTER this frame's Main spawn + Player move + Bullet moves.
	var player: Area2D = main.player
	var bullets_node: Node2D = main.bullets
	var bl: Array = []
	for c in bullets_node.get_children():
		if c is Area2D:
			var sh: Shape2D = c.get_node("CollisionShape2D").shape
			var r := 2.0
			if sh is CircleShape2D:
				r = (sh as CircleShape2D).radius
			bl.append({
				"x": c.global_position.x,
				"y": c.global_position.y,
				"vx": c.velocity.x,
				"vy": c.velocity.y,
				"kind": c.kind,
				"r": r,
			})
	var row := {
		"kind": "frame",
		"frame": frame,
		"action": pending_action,
		"elapsed": main.elapsed,
		"spawn_acc": main.spawn_acc,
		"dead": player.dead,
		"player": {
			"x": player.global_position.x,
			"y": player.global_position.y,
			"vx": player.velocity.x,
			"vy": player.velocity.y,
		},
		"bullets": bl,
	}
	file.store_line(JSON.stringify(row))
	frame += 1

	if player.dead or frame >= max_frames or main.state == main.State.GAMEOVER:
		file.store_line(JSON.stringify({"kind": "end", "frames": frame, "elapsed": main.elapsed}))
		file.flush()
		file = null
		get_tree().quit()
		return

	# Choose action for the NEXT physics frame (applied before Main spawn via main.monkey_tick).
	var ai := monkey_rng.randi_range(0, actions.size() - 1)
	pending_action = actions[ai]
	player.use_force_dir = true
	player.force_dir = dirs[ai]


func begin() -> void:
	started = true
	pending_action = "idle"
	var player: Area2D = main.player
	player.use_force_dir = true
	player.force_dir = Vector2.ZERO
