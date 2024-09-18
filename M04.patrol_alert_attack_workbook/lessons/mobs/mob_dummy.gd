extends CharacterBody3D

@export var projectile_scene: PackedScene = null
@export var explosion_scene: PackedScene = null

@onready var shooting_point: Marker3D = %ShootingPoint
@onready var explosion_proximity_3d: Area3D = %ExplosionPromixity3D

enum States {
	LOOK_AT_PLAYER,
	WAIT,
	FIRE_PROJECTILE,
	EXPLODE,
}

var current_state: States = States.LOOK_AT_PLAYER:
	set = set_current_state

func set_current_state(new_state: States) -> void:
	# Prevent exploding more than once
	if current_state == States.EXPLODE and new_state == States.EXPLODE:
		return

	current_state = new_state

	match current_state:
		States.LOOK_AT_PLAYER:
			get_tree().create_timer(2.0).timeout.connect(
				set_current_state.bind(States.WAIT)
			)
		States.WAIT:
			get_tree().create_timer(0.5).timeout.connect(
				set_current_state.bind(States.FIRE_PROJECTILE)
			)
		States.FIRE_PROJECTILE:
			fire_projectile()
			get_tree().create_timer(0.5).timeout.connect(
				set_current_state.bind(States.LOOK_AT_PLAYER)
			)
		States.EXPLODE:
			# TODO: Animate blinking and scaling before explosion
			explode()
			queue_free()


var player: CharacterBody3D = null

func _ready() -> void:
	player = get_tree().root.get_node("Level/Player3D")
	set_current_state(States.LOOK_AT_PLAYER)

	explosion_proximity_3d.body_entered.connect( func _on_explosion_proximity_3d_body_entered(body: Node3D) -> void:
		if current_state == States.LOOK_AT_PLAYER and body is Player3DWithBlackboard:
			set_current_state(States.EXPLODE)
	)

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

func fire_projectile():
	var projectile: Projectile3D = projectile_scene.instantiate()
	owner.add_sibling(projectile)
	projectile.global_transform = shooting_point.global_transform

func explode():
	var explosion = explosion_scene.instantiate()
	owner.add_sibling(explosion)
	explosion.global_position = global_position


