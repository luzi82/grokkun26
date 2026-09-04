extends Node2D
## Grokkun — title / play / game-over. One endless wave.

enum State { TITLE, PLAYING, GAMEOVER }

const BULLET_SCENE := preload("res://scenes/bullet.tscn")
const TEX_TOKKUN := preload("res://assets/tokkun.png")

const COL_GOLD := Color("ffcc44")
const COL_CREAM := Color("fff4d2")
const COL_MUTED := Color("c4b89a")
const COL_TIME := Color("ffe566")
const COL_RANK := Color("7ee8ff")
const COL_PROMPT := Color("ffd27a")

@onready var player: Area2D = $Player
@onready var bullets: Node2D = $Bullets
@onready var ui: CanvasLayer = $UI

var state: int = State.TITLE
var elapsed: float = 0.0
var spawn_acc: float = 0.0
var rng := RandomNumberGenerator.new()
var monkey: Node = null
var monkey_mode: bool = false

var hud_time: PixelText
var title_name: PixelText
var title_tribute: PixelText
var title_credit: PixelText
var title_prompt: PixelText
var title_best: PixelText
var tokkun_sprite: Sprite2D
var dim: ColorRect
var over_time: PixelText
var over_rank: PixelText
var over_best: PixelText
var over_prompt: PixelText
var flash: ColorRect
var flash_t: float = 0.0


func _ready() -> void:
	monkey_mode = OS.get_environment("GROKKUN_MONKEY") == "1"
	if monkey_mode:
		var seed := int(OS.get_environment("GROKKUN_SEED"))
		if OS.get_environment("GROKKUN_SEED") == "":
			seed = 42
		rng.seed = seed
	else:
		rng.randomize()
	player.died.connect(_on_player_died)
	player.freeze()
	player.place_center()
	_build_ui()
	_show_title()
	if monkey_mode:
		call_deferred("_monkey_boot")


func _monkey_boot() -> void:
	var seed := int(OS.get_environment("GROKKUN_SEED"))
	if OS.get_environment("GROKKUN_SEED") == "":
		seed = 42
	var out_path := OS.get_environment("GROKKUN_OUT")
	if out_path == "":
		out_path = "user://monkey.jsonl"
	var frames := int(OS.get_environment("GROKKUN_FRAMES"))
	if frames <= 0:
		frames = 300
	monkey = Node.new()
	monkey.set_script(load("res://scripts/monkey_recorder.gd"))
	add_child(monkey)
	monkey.setup(self, seed, out_path, frames)
	_start_run()
	monkey.begin()


func _build_ui() -> void:
	dim = ColorRect.new()
	dim.color = Color(0.06, 0.03, 0.1, 0.58)
	dim.size = Vector2(320, 240)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dim.visible = false
	ui.add_child(dim)

	flash = ColorRect.new()
	flash.color = Color(1.0, 0.25, 0.35, 0.0)
	flash.size = Vector2(320, 240)
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.add_child(flash)

	hud_time = _px("0.0", Vector2(160, 5), 1, COL_TIME, 1)

	title_name = _px("GROKKUN", Vector2(160, 46), 3, COL_GOLD, 1)
	tokkun_sprite = Sprite2D.new()
	tokkun_sprite.texture = TEX_TOKKUN
	tokkun_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	tokkun_sprite.position = Vector2(118, 88)
	tokkun_sprite.centered = true
	ui.add_child(tokkun_sprite)
	title_tribute = _px("TRIBUTE", Vector2(178, 84), 1, COL_GOLD, 0)
	title_credit = _px("MADE BY GROK BOT", Vector2(160, 108), 1, COL_MUTED, 1)
	title_prompt = _px("PRESS Z / SPACE", Vector2(160, 150), 1, COL_PROMPT, 1)
	title_best = _px("", Vector2(160, 200), 1, COL_CREAM, 1)

	over_time = _px("", Vector2(160, 64), 2, COL_TIME, 1)
	over_rank = _px("", Vector2(160, 92), 2, COL_RANK, 1)
	over_best = _px("", Vector2(160, 124), 1, COL_MUTED, 1)
	over_prompt = _px("PRESS Z / SPACE", Vector2(160, 164), 1, COL_PROMPT, 1)


func _px(text: String, pos: Vector2, sc: int, col: Color, align: int) -> PixelText:
	var n := PixelText.new()
	n.text = text
	n.px_scale = sc
	n.color = col
	n.align = align
	n.position = pos
	ui.add_child(n)
	return n


func _physics_process(delta: float) -> void:
	if flash_t > 0.0:
		flash_t = maxf(0.0, flash_t - delta)
		flash.color.a = flash_t / 0.18 * 0.45

	match state:
		State.TITLE:
			if not monkey_mode and title_prompt != null:
				title_prompt.visible = int(Time.get_ticks_msec() / 420) % 2 == 0
			if (not monkey_mode) and Input.is_action_just_pressed("start"):
				_start_run()
		State.PLAYING:
			elapsed += delta
			if hud_time != null:
				hud_time.text = "%.1f" % elapsed
			_spawn_step(delta)
		State.GAMEOVER:
			if not monkey_mode and over_prompt != null:
				over_prompt.visible = int(Time.get_ticks_msec() / 420) % 2 == 0
			if (not monkey_mode) and Input.is_action_just_pressed("start"):
				_start_run()


func _start_run() -> void:
	for c in bullets.get_children():
		c.queue_free()
	elapsed = 0.0
	spawn_acc = -0.7
	player.place_center()
	player.arm()
	state = State.PLAYING
	_show_play()


func _on_player_died() -> void:
	if state != State.PLAYING:
		return
	state = State.GAMEOVER
	player.freeze()
	for c in bullets.get_children():
		c.set_physics_process(false)
	var rank := GameState.record(elapsed)
	over_time.text = "%.1f" % elapsed
	over_rank.text = rank
	over_best.text = "BEST %.1f" % GameState.best_time
	flash_t = 0.18
	_show_gameover()


func _spawn_step(delta: float) -> void:
	spawn_acc += delta
	var interval := _spawn_interval()
	while spawn_acc >= interval:
		spawn_acc -= interval
		_spawn_one()
		if elapsed > 18.0 and rng.randf() < 0.16:
			_spawn_one()
		interval = _spawn_interval()


func _spawn_interval() -> float:
	var t := elapsed
	if t < 8.0:
		return lerpf(0.48, 0.32, t / 8.0)
	if t < 20.0:
		return lerpf(0.32, 0.20, (t - 8.0) / 12.0)
	if t < 35.0:
		return lerpf(0.20, 0.12, (t - 20.0) / 15.0)
	if t < 55.0:
		return lerpf(0.12, 0.075, (t - 35.0) / 20.0)
	if t < 80.0:
		return lerpf(0.075, 0.048, (t - 55.0) / 25.0)
	return 0.042


func _bullet_speed() -> float:
	return lerpf(46.0, 125.0, clampf(elapsed / 70.0, 0.0, 1.0))


func _spawn_one() -> void:
	var field: Rect2 = GameState.FIELD
	var edge := rng.randi_range(0, 3)
	var pos := Vector2.ZERO
	match edge:
		0:
			pos = Vector2(rng.randf_range(field.position.x, field.end.x), field.position.y - 8.0)
		1:
			pos = Vector2(rng.randf_range(field.position.x, field.end.x), field.end.y + 8.0)
		2:
			pos = Vector2(field.position.x - 8.0, rng.randf_range(field.position.y, field.end.y))
		_:
			pos = Vector2(field.end.x + 8.0, rng.randf_range(field.position.y, field.end.y))
	var speed := _bullet_speed() * rng.randf_range(0.88, 1.14)
	var vel := Vector2.ZERO
	var aim_p := clampf(0.22 + elapsed * 0.006, 0.22, 0.55)
	if rng.randf() < aim_p:
		var miss := rng.randf_range(8.0, 34.0)
		var target := player.global_position + Vector2.from_angle(rng.randf() * TAU) * miss
		vel = (target - pos).normalized() * speed
	else:
		var center := field.position + field.size * 0.5
		var inward := (center - pos).normalized()
		var jitter := deg_to_rad(rng.randf_range(-50.0, 50.0))
		vel = inward.rotated(jitter) * speed
	var kind := 0
	var roll := rng.randf()
	if elapsed > 25.0 and roll < 0.12:
		kind = 2
		vel *= 0.62
	elif roll < 0.18:
		kind = 3
		vel *= 1.15
	elif roll < 0.55:
		kind = 1
	else:
		kind = 0
	var b: Area2D = BULLET_SCENE.instantiate()
	bullets.add_child(b)
	b.setup(pos, vel, kind)


func _show_title() -> void:
	hud_time.visible = false
	title_name.visible = true
	title_tribute.visible = true
	title_credit.visible = true
	title_prompt.visible = true
	tokkun_sprite.visible = true
	if GameState.best_time > 0.0:
		title_best.text = "BEST %.1f  %s" % [GameState.best_time, Ranks.title_for(GameState.best_time)]
		title_best.visible = true
	else:
		title_best.visible = false
	dim.visible = false
	over_time.visible = false
	over_rank.visible = false
	over_best.visible = false
	over_prompt.visible = false
	player.visible = true


func _show_play() -> void:
	hud_time.visible = true
	hud_time.text = "0.0"
	title_name.visible = false
	title_tribute.visible = false
	title_credit.visible = false
	title_prompt.visible = false
	title_best.visible = false
	tokkun_sprite.visible = false
	dim.visible = false
	over_time.visible = false
	over_rank.visible = false
	over_best.visible = false
	over_prompt.visible = false


func _show_gameover() -> void:
	hud_time.visible = true
	title_name.visible = false
	title_tribute.visible = false
	title_credit.visible = false
	title_prompt.visible = false
	title_best.visible = false
	tokkun_sprite.visible = false
	dim.visible = true
	over_time.visible = true
	over_rank.visible = true
	over_best.visible = true
	over_prompt.visible = true
