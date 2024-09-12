extends CharacterBody3D


enum States {
	LOOK_AT_PLAYER,
	WAIT,
	FIRE_PROJECTILE,
	EXPLODE,
}

@export var projectile_scene: PackedScene = null

var current_state: States = States.LOOK_AT_PLAYER:
	set = set_current_state
var player: CharacterBody3D = null

@onready var shooting_point: Node3D = %ShootingPoint
@onready var area_3d: Area3D = %Area3D
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var explosion_spawning_point: Marker3D = %ExplosionSpawningPoint


func _ready() -> void:
	player = get_tree().root.get_node_or_null("Level/Player3D")
	set_current_state(States.LOOK_AT_PLAYER)


func set_current_state(new_state: States) -> void:
	if current_state == States.EXPLODE:
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
			var projectile: Projectile3D = projectile_scene.instantiate()
			add_sibling(projectile)

			projectile.global_position = shooting_point.global_position
			projectile.look_at(
				shooting_point.global_position + shooting_point.global_basis.z
			)
			get_tree().create_timer(0.5).timeout.connect(
				set_current_state.bind(States.LOOK_AT_PLAYER)
			)
		States.EXPLODE:
			animation_player.play("explode")




func _physics_process(delta: float) -> void:
	match current_state:
		States.LOOK_AT_PLAYER:
			var direction := global_position.direction_to(player.global_position)
			var target_rotation_y := Vector3.FORWARD.signed_angle_to(direction, Vector3.UP) + PI
			rotation.y = lerp_angle(rotation.y, target_rotation_y, 2.0 * delta)

	if current_state != States.EXPLODE and not area_3d.get_overlapping_bodies().is_empty():
		set_current_state(States.EXPLODE)


func spawn_explosion() -> void:
	const EXPLOSION = preload("res://assets/vfx/explosion/explosion.tscn")
	var explosion: Node3D = EXPLOSION.instantiate()
	add_sibling(explosion)
	explosion.global_position = explosion_spawning_point.global_position
