extends Node2D
## Original playfield: dark navy, gold corner brackets, star specks.

var stars: Array[Vector2] = []
var star_a: Array[float] = []


func _ready() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 99099
	for i in 52:
		stars.append(Vector2(rng.randf_range(0.0, 320.0), rng.randf_range(0.0, 240.0)))
		star_a.append(rng.randf_range(0.18, 0.72))
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(0, 0, 320, 240), Color("120c1c"))
	var f: Rect2 = GameState.FIELD
	draw_rect(f, Color("1b1430"))
	draw_rect(f.grow(-1.0), Color("3d2f5c"), false, 1.0)
	var c := Color("c9a84c")
	var L := 8.0
	var p := f.position
	var e := f.end
	draw_line(p, p + Vector2(L, 0), c, 1.0)
	draw_line(p, p + Vector2(0, L), c, 1.0)
	draw_line(Vector2(e.x, p.y), Vector2(e.x - L, p.y), c, 1.0)
	draw_line(Vector2(e.x, p.y), Vector2(e.x, p.y + L), c, 1.0)
	draw_line(Vector2(p.x, e.y), Vector2(p.x + L, e.y), c, 1.0)
	draw_line(Vector2(p.x, e.y), Vector2(p.x, e.y - L), c, 1.0)
	draw_line(e, e + Vector2(-L, 0), c, 1.0)
	draw_line(e, e + Vector2(0, -L), c, 1.0)
	for i in stars.size():
		if f.has_point(stars[i]):
			draw_rect(Rect2(stars[i], Vector2.ONE), Color(0.85, 0.8, 1.0, star_a[i]))
