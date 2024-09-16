extends CharacterBody3D

enum States {
	LOOK_AT_PLAYER,
	WAIT,
	FIRE_PROJECTILE,
}

var current_state: States = States.LOOK_AT_PLAYER:
	set = set_current_state

func set_current_state(new_state: States) -> void:
	current_state = new_state

var player: CharacterBody3D = null

func _ready() -> void:
	player = get_tree().root.get_node("Level/Player3D")

func _physics_process(delta):
	match current_state:
		States.LOOK_AT_PLAYER:
			var direction := global_position.direction_to(
				player.global_position
			)
			var target_rotation_y := Vector3.FORWARD.signed_angle_to(
				direction, Vector3.UP
			) + PI
			rotation.y = lerp_angle(
				rotation.y, target_rotation_y, 2.0 * delta
			)
