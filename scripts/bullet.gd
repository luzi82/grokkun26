extends Area2D

var velocity: Vector2 = Vector2.ZERO

const TEX_SMALL := preload("res://assets/bullet_small.png")
const TEX_MED := preload("res://assets/bullet_med.png")
const TEX_BIG := preload("res://assets/bullet_big.png")
const TEX_LIME := preload("res://assets/bullet_lime.png")


func setup(pos: Vector2, vel: Vector2, kind: int) -> void:
	global_position = pos
	velocity = vel
	var sprite: Sprite2D = $Sprite2D
	var cs := CircleShape2D.new()
	match kind:
		2:
			sprite.texture = TEX_BIG
			cs.radius = 3.4
		3:
			sprite.texture = TEX_LIME
			cs.radius = 2.0
		1:
			sprite.texture = TEX_MED
			cs.radius = 2.6
		_:
			sprite.texture = TEX_SMALL
			cs.radius = 2.0
	$CollisionShape2D.shape = cs


func _physics_process(delta: float) -> void:
	position += velocity * delta
	if position.x < -24.0 or position.x > 344.0 or position.y < -24.0 or position.y > 264.0:
		queue_free()
