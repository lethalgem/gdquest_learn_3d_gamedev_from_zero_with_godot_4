extends Node3D

var mouse_position_2d := Vector2.ZERO
var mouse_ray := Vector3.ZERO
var world_mouse_position: Variant = null


var _world_plane := Plane(Vector3.UP)

@onready var _camera_3d: Camera3D = %Camera3D


func _physics_process(delta: float) -> void:
	_world_plane.d = global_position.y

	if Input.is_action_just_pressed("left_click"):
		# This code is the same as in previous practices. We calculate the projected mouse position.
		mouse_position_2d = get_viewport().get_mouse_position()
		mouse_ray = _camera_3d.project_ray_normal(mouse_position_2d)
		world_mouse_position = _world_plane.intersects_ray(_camera_3d.global_position, mouse_ray)
		
		# Preload the box scene file, instantiate it, add it as a child of this
		# node, and set its global position to the projected mouse position.
		const BoxScene := preload("res://addons/gdpractice/practice_solutions/L5.P3/box.tscn") #
		var box := BoxScene.instantiate() #
		add_child(box) #
		box.global_position = world_mouse_position #
