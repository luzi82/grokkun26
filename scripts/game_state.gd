extends Node
## Autoload: playfield bounds, best time, input bindings.

const VIEW := Vector2(320, 240)
const FIELD := Rect2(8, 20, 304, 212)

var best_time: float = 0.0
var last_time: float = 0.0
var last_rank: String = "SPARK"

const SAVE_PATH := "user://grokkun.cfg"


func _ready() -> void:
	_bind_inputs()
	_load()


func record(seconds: float) -> String:
	last_time = seconds
	last_rank = Ranks.title_for(seconds)
	if seconds > best_time:
		best_time = seconds
		_save()
	return last_rank


func _bind_inputs() -> void:
	_ensure_action("start", [KEY_ENTER, KEY_KP_ENTER, KEY_SPACE, KEY_Z])
	_ensure_action("move_left", [KEY_LEFT, KEY_A])
	_ensure_action("move_right", [KEY_RIGHT, KEY_D])
	_ensure_action("move_up", [KEY_UP, KEY_W])
	_ensure_action("move_down", [KEY_DOWN, KEY_S])


func _ensure_action(action: String, keys: Array) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	for k in keys:
		var e := InputEventKey.new()
		e.physical_keycode = k
		if not InputMap.action_has_event(action, e):
			InputMap.action_add_event(action, e)


func _load() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) == OK:
		best_time = float(cfg.get_value("score", "best", 0.0))


func _save() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("score", "best", best_time)
	cfg.save(SAVE_PATH)
