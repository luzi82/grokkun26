class_name PixelText
extends Node2D
## 5x7 pixel label.

@export var text: String = "":
	set(v):
		text = v
		queue_redraw()

@export var color: Color = Color(1, 1, 1, 1):
	set(v):
		color = v
		queue_redraw()

@export var px_scale: int = 1:
	set(v):
		px_scale = maxi(1, v)
		queue_redraw()

@export var align: int = 0:
	set(v):
		align = v
		queue_redraw()

@export var shadow: bool = true:
	set(v):
		shadow = v
		queue_redraw()


func _draw() -> void:
	PixelFont.draw_text(self, Vector2.ZERO, text, color, px_scale, align, shadow)
