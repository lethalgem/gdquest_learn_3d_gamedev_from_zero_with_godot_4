extends Node3D

var speed := 10.0
var max_range := 10.0
var _traveled_distance := 0.0


func _physics_process(delta: float) -> void:
	var distance := speed * delta
	var motion := -transform.basis.z * distance

	position += motion
	_traveled_distance += distance
	if _traveled_distance > max_range:
		queue_free()
