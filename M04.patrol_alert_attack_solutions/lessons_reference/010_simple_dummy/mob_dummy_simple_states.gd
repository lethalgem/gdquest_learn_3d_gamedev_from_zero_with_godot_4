extends CharacterBody3D

#ANCHOR:states
enum States {
	LOOK_AT_PLAYER,
	WAIT,
	FIRE_PROJECTILE,
}
#END:states

#ANCHOR:var_projectile_scene
@export var projectile_scene: PackedScene = null
#END:var_projectile_scene

#ANCHOR:var_state
var current_state: States = States.LOOK_AT_PLAYER:
	set = set_current_state
#END:var_state
#ANCHOR:var_player
var player: CharacterBody3D = null
#END:var_player

#ANCHOR:var_shooting_point
@onready var shooting_point: Node3D = %ShootingPoint
#END:var_shooting_point


#ANCHOR:ready_definition
func _ready() -> void:
#END:ready_definition
#ANCHOR:ready_find_player
	player = get_tree().root.get_node("Level/Player3D")
#END:ready_find_player

#ANCHOR:ready_set_state
	set_current_state(States.LOOK_AT_PLAYER)
#END:ready_set_state


#ANCHOR:set_state_definition
func set_current_state(new_state: States) -> void:
#END:set_state_definition
#ANCHOR:set_state_assign
	current_state = new_state
#END:set_state_assign

#ANCHOR:set_state_first_two_states
#ANCHOR:set_state_look_at_player
	match current_state:
		States.LOOK_AT_PLAYER:
			get_tree().create_timer(2.0).timeout.connect(
				set_current_state.bind(States.WAIT)
			)
#END:set_state_look_at_player
		States.WAIT:
			get_tree().create_timer(0.5).timeout.connect(
				set_current_state.bind(States.FIRE_PROJECTILE)
			)
#END:set_state_first_two_states
#ANCHOR:set_state_fire_projectile
		States.FIRE_PROJECTILE:
			var projectile: Projectile3D = projectile_scene.instantiate()
			add_sibling(projectile)

			projectile.global_position = shooting_point.global_position
			projectile.look_at(
				shooting_point.global_position + shooting_point.global_basis.z
			)
			get_tree().create_timer(0.5).timeout.connect(
				set_current_state.bind(States.LOOK_AT_PLAYER)
			)
#END:set_state_fire_projectile


#ANCHOR:physics_process
func _physics_process(delta: float) -> void:
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
#END:physics_process
