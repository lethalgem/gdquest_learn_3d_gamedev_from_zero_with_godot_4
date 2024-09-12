extends Node

@onready var _game_over_screen: CanvasLayer = %GameOverScreen
@onready var _restart_button: Button = %RestartButton
@onready var _kill_plane_3d: Area3D = %KillPlane3D
@onready var _player_3d: Player3D = %Player3D


func _ready() -> void:
	_restart_button.pressed.connect(get_tree().reload_current_scene, CONNECT_DEFERRED)
	_kill_plane_3d.body_entered.connect(func (_body: CharacterBody3D) -> void:
		get_tree().reload_current_scene(),
		CONNECT_DEFERRED
	)
	_player_3d.died.connect(_game_over_screen.show)
