extends Node3D

const MobFollow := preload("mob_follow.gd")

var radius := 2.0
var speed := 4.0
var angle := 0.0

@onready var start_global_position := global_position

func _physics_process(delta: float) -> void:
	angle += speed * delta / radius
	global_position = start_global_position + Vector3(radius * cos(angle), 0.0, radius * sin(angle))

	MobFollow.Blackboard.ball_global_position = global_position
