extends CharacterBody3D

# I added this signal to the practice to detect when the turret state changes.
signal state_changed(new_state: States)

enum States {
	WAIT,
}

var bullet_scene: PackedScene = preload("bullet.tscn")
var current_state: States = States.WAIT: set = set_current_state

@onready var bullet_spawning_point: Node3D = %BulletSpawningPoint


func _ready() -> void:
	# Don't forget to call the setter to initialize to the WAIT state.
	pass


func set_current_state(new_state: States) -> void:
	# This signal is used by the practice system to test when the turret state changes.
	# You can ignore it.
	if new_state != current_state:
		state_changed.emit(new_state)

	current_state = new_state

	match current_state:
		States.WAIT:
			pass
