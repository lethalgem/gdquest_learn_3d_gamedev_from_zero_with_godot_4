extends CharacterBody3D

# I added this signal to the practice to detect when the turret state changes.
signal state_changed(new_state: States)

enum States {
	WAIT,
	SHOOT, #
}

var bullet_scene: PackedScene = preload("bullet.tscn")
var current_state: States = States.WAIT: set = set_current_state

@onready var bullet_spawning_point: Node3D = %BulletSpawningPoint


func _ready() -> void:
	# Don't forget to call the setter to initialize to the WAIT state.
	set_current_state(States.WAIT) # pass


func set_current_state(new_state: States) -> void:
	# This signal is used by the practice system to test when the turret state changes.
	# You can ignore it.
	if new_state != current_state:
		state_changed.emit(new_state)

	current_state = new_state

	match current_state:
		States.WAIT:
			get_tree().create_timer(0.7).timeout.connect( # pass
				set_current_state.bind(States.SHOOT) #
			) #
		States.SHOOT: #
			var bullet = bullet_scene.instantiate() #
			add_sibling(bullet) #

			bullet.global_position = bullet_spawning_point.global_position #
			bullet.look_at( #
				bullet_spawning_point.global_position + bullet_spawning_point.global_basis.z #
			) #
			set_current_state(States.WAIT) #
