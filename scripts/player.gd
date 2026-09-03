extends Area2D
## Tiny ship. Light inertia, snappy stop. Hitbox is slightly smaller than the sprite.

signal died

const MAX_SPEED := 102.0
const ACCEL := 980.0
const FRICTION := 1400.0
const MARGIN := 6.0

var velocity: Vector2 = Vector2.ZERO
var locked: bool = true
var dead: bool = false


func _ready() -> void:
	area_entered.connect(_on_area_entered)


func _physics_process(delta: float) -> void:
	if locked or dead:
		velocity = Vector2.ZERO
		return
	var dir := Vector2.ZERO
	if Input.is_action_pressed("move_left"):
		dir.x -= 1.0
	if Input.is_action_pressed("move_right"):
		dir.x += 1.0
	if Input.is_action_pressed("move_up"):
		dir.y -= 1.0
	if Input.is_action_pressed("move_down"):
		dir.y += 1.0
	if dir != Vector2.ZERO:
		dir = dir.normalized()
		velocity = velocity.move_toward(dir * MAX_SPEED, ACCEL * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	global_position += velocity * delta
	var field: Rect2 = GameState.FIELD
	global_position.x = clampf(global_position.x, field.position.x + MARGIN, field.end.x - MARGIN)
	global_position.y = clampf(global_position.y, field.position.y + MARGIN, field.end.y - MARGIN)


func _on_area_entered(area: Area2D) -> void:
	if locked or dead:
		return
	if area.is_in_group("bullets"):
		dead = true
		locked = true
		died.emit()


func arm() -> void:
	dead = false
	locked = false
	modulate = Color.WHITE
	velocity = Vector2.ZERO
	visible = true


func freeze() -> void:
	locked = true
	velocity = Vector2.ZERO


func place_center() -> void:
	var field: Rect2 = GameState.FIELD
	global_position = field.position + field.size * 0.5
	velocity = Vector2.ZERO
