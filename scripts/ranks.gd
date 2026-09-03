class_name Ranks
extends RefCounted
## Original rank ladder. 30s is a brag; ~60s is elite.

const LADDER := [
	{"t": 0.0, "name": "SPARK"},
	{"t": 5.0, "name": "GLINT"},
	{"t": 10.0, "name": "NEEDLE"},
	{"t": 15.0, "name": "RAZOR"},
	{"t": 22.0, "name": "ARC"},
	{"t": 30.0, "name": "GROKKER"},
	{"t": 40.0, "name": "STORMCUT"},
	{"t": 50.0, "name": "IRONWAKE"},
	{"t": 60.0, "name": "APEX"},
	{"t": 75.0, "name": "MYTHOS"},
	{"t": 90.0, "name": "VOIDPILOT"},
	{"t": 120.0, "name": "ETERNAL"},
]


static func title_for(seconds: float) -> String:
	var name := "SPARK"
	for row in LADDER:
		if seconds + 0.0001 >= float(row["t"]):
			name = String(row["name"])
		else:
			break
	return name
