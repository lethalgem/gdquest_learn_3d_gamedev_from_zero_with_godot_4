extends Node

@onready var _player: PlayerFPSController = %Player
@onready var _kill_plane: Area3D = %KillPlane
@onready var _terrain: Node3D = %Terrain

@onready var _player_start_position := _player.global_position


func _ready() -> void:
	_create_terrain_shadow_copy()

	_kill_plane.body_entered.connect(func (body: CharacterBody3D) -> void:
		if body is PlayerFPSController:
			_player.global_position = _player_start_position
	)


## Creates a copy of the ground to correctly cast shadows on the character model.
func _create_terrain_shadow_copy() -> void:
	var environment_copy: Node3D = _terrain.duplicate()

	var geometry_instances: Array[GeometryInstance3D] = []
	for child in environment_copy.get_children():
		if child is GeometryInstance3D:
			geometry_instances.append(child)

	for instance in geometry_instances:
		instance.layers = 0b10
		instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY

	add_child(environment_copy)
