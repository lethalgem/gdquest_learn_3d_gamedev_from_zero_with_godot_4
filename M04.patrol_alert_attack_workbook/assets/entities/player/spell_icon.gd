extends TextureRect

var active : bool = false : set = _set_active

func _ready():
	modulate.a = 0.25

func _set_active(state : bool):
	if active == state: return
	active = state
	var t = create_tween()
	t.tween_property(self, "modulate:a", 1.0 if active else 0.25, 0.25)
