class_name PixelFont
extends RefCounted
## Tiny 5x7 bitmap font for Qrokkun HUD / menus.

const GW := 5
const GH := 7
const GAP := 1

const GLYPHS := {
	" ": [0, 0, 0, 0, 0, 0, 0],
	"0": [0b01110, 0b10001, 0b10011, 0b10101, 0b11001, 0b10001, 0b01110],
	"1": [0b00100, 0b01100, 0b00100, 0b00100, 0b00100, 0b00100, 0b01110],
	"2": [0b01110, 0b10001, 0b00001, 0b00010, 0b00100, 0b01000, 0b11111],
	"3": [0b01110, 0b10001, 0b00001, 0b00110, 0b00001, 0b10001, 0b01110],
	"4": [0b00010, 0b00110, 0b01010, 0b10010, 0b11111, 0b00010, 0b00010],
	"5": [0b11111, 0b10000, 0b11110, 0b00001, 0b00001, 0b10001, 0b01110],
	"6": [0b01110, 0b10000, 0b11110, 0b10001, 0b10001, 0b10001, 0b01110],
	"7": [0b11111, 0b00001, 0b00010, 0b00100, 0b01000, 0b01000, 0b01000],
	"8": [0b01110, 0b10001, 0b10001, 0b01110, 0b10001, 0b10001, 0b01110],
	"9": [0b01110, 0b10001, 0b10001, 0b01111, 0b00001, 0b00001, 0b01110],
	"A": [0b01110, 0b10001, 0b10001, 0b11111, 0b10001, 0b10001, 0b10001],
	"B": [0b11110, 0b10001, 0b10001, 0b11110, 0b10001, 0b10001, 0b11110],
	"C": [0b01110, 0b10001, 0b10000, 0b10000, 0b10000, 0b10001, 0b01110],
	"D": [0b11110, 0b10001, 0b10001, 0b10001, 0b10001, 0b10001, 0b11110],
	"E": [0b11111, 0b10000, 0b10000, 0b11110, 0b10000, 0b10000, 0b11111],
	"F": [0b11111, 0b10000, 0b10000, 0b11110, 0b10000, 0b10000, 0b10000],
	"G": [0b01110, 0b10001, 0b10000, 0b10111, 0b10001, 0b10001, 0b01110],
	"H": [0b10001, 0b10001, 0b10001, 0b11111, 0b10001, 0b10001, 0b10001],
	"I": [0b01110, 0b00100, 0b00100, 0b00100, 0b00100, 0b00100, 0b01110],
	"J": [0b00111, 0b00010, 0b00010, 0b00010, 0b00010, 0b10010, 0b01100],
	"K": [0b10001, 0b10010, 0b10100, 0b11000, 0b10100, 0b10010, 0b10001],
	"L": [0b10000, 0b10000, 0b10000, 0b10000, 0b10000, 0b10000, 0b11111],
	"M": [0b10001, 0b11011, 0b10101, 0b10101, 0b10001, 0b10001, 0b10001],
	"N": [0b10001, 0b11001, 0b10101, 0b10011, 0b10001, 0b10001, 0b10001],
	"O": [0b01110, 0b10001, 0b10001, 0b10001, 0b10001, 0b10001, 0b01110],
	"P": [0b11110, 0b10001, 0b10001, 0b11110, 0b10000, 0b10000, 0b10000],
	"Q": [0b01110, 0b10001, 0b10001, 0b10001, 0b10101, 0b10010, 0b01101],
	"R": [0b11110, 0b10001, 0b10001, 0b11110, 0b10100, 0b10010, 0b10001],
	"S": [0b01111, 0b10000, 0b10000, 0b01110, 0b00001, 0b00001, 0b11110],
	"T": [0b11111, 0b00100, 0b00100, 0b00100, 0b00100, 0b00100, 0b00100],
	"U": [0b10001, 0b10001, 0b10001, 0b10001, 0b10001, 0b10001, 0b01110],
	"V": [0b10001, 0b10001, 0b10001, 0b10001, 0b10001, 0b01010, 0b00100],
	"W": [0b10001, 0b10001, 0b10001, 0b10101, 0b10101, 0b11011, 0b10001],
	"X": [0b10001, 0b10001, 0b01010, 0b00100, 0b01010, 0b10001, 0b10001],
	"Y": [0b10001, 0b10001, 0b01010, 0b00100, 0b00100, 0b00100, 0b00100],
	"Z": [0b11111, 0b00001, 0b00010, 0b00100, 0b01000, 0b10000, 0b11111],
	".": [0, 0, 0, 0, 0, 0b01100, 0b01100],
	"/": [0b00001, 0b00010, 0b00010, 0b00100, 0b01000, 0b01000, 0b10000],
	"-": [0, 0, 0, 0b11111, 0, 0, 0],
	":": [0, 0b01100, 0b01100, 0, 0b01100, 0b01100, 0],
	"!": [0b00100, 0b00100, 0b00100, 0b00100, 0b00100, 0, 0b00100],
	"?": [0b01110, 0b10001, 0b00001, 0b00010, 0b00100, 0, 0b00100],
}


static func text_width(text: String, px_scale: int = 1) -> int:
	var n := text.length()
	if n <= 0:
		return 0
	return n * (GW + GAP) * px_scale - GAP * px_scale


static func text_height(px_scale: int = 1) -> int:
	return GH * px_scale


static func draw_text(ci: CanvasItem, origin: Vector2, text: String, color: Color, px_scale: int = 1, align: int = 0, shadow: bool = true) -> void:
	var s := text.to_upper()
	var w := text_width(s, px_scale)
	var pos := origin
	if align == 1:
		pos.x -= w * 0.5
	elif align == 2:
		pos.x -= float(w)
	if shadow:
		var sh := Color(0.05, 0.02, 0.08, color.a * 0.85)
		_draw_string_at(ci, pos + Vector2(px_scale, px_scale), s, sh, px_scale)
	_draw_string_at(ci, pos, s, color, px_scale)


static func _draw_string_at(ci: CanvasItem, pos: Vector2, s: String, color: Color, px_scale: int) -> void:
	var x := pos.x
	for i in s.length():
		_draw_glyph(ci, Vector2(x, pos.y), s.substr(i, 1), color, px_scale)
		x += (GW + GAP) * px_scale


static func _draw_glyph(ci: CanvasItem, pos: Vector2, ch: String, color: Color, px_scale: int) -> void:
	if not GLYPHS.has(ch):
		ch = "?"
	var rows: Array = GLYPHS[ch]
	for row in GH:
		var bits: int = int(rows[row])
		for col in GW:
			var mask := 1 << (GW - 1 - col)
			if bits & mask:
				ci.draw_rect(Rect2(pos.x + col * px_scale, pos.y + row * px_scale, px_scale, px_scale), color)
