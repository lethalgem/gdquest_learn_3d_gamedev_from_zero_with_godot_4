class_name MobBeeNoStates3D extends Mob3D

@export var projectile_scene: PackedScene = null

var player: CharacterBody3D = null

#ANCHOR: booleans
var is_looking_at_player := true: set = set_is_looking_at_player
var is_waiting := false: set = set_is_waiting
var is_firing_projectile := false: set = set_is_firing_projectile
#END: booleans

@onready var shooting_point: Node3D = %ShootingPoint
@onready var timer: Timer = %Timer


func _ready() -> void:
	player = get_tree().root.get_node("Game/Player3D")


func _physics_process(delta: float) -> void:

	if is_looking_at_player:
		var direction := global_position.direction_to(player.global_position)
		var target_rotation_y := Vector3.FORWARD.signed_angle_to(direction, Vector3.UP) + PI
		rotation.y = lerp_angle(rotation.y, target_rotation_y, 2.0 * delta)


#ANCHOR: set_is_looking_at_player_start
func set_is_looking_at_player(value: bool) -> void:
	is_looking_at_player = value
	if is_looking_at_player == true:
#END: set_is_looking_at_player_start
		get_tree().create_timer(2.0).timeout.connect(func () -> void:
			is_looking_at_player = false
			is_waiting = true
		)


#ANCHOR: set_is_waiting_start
func set_is_waiting(value: bool) -> void:
	is_waiting = value
	if is_waiting == true:
#END: set_is_waiting_start
#ANCHOR: set_is_waiting_timer
		get_tree().create_timer(0.5).timeout.connect(func () -> void:
			is_waiting = false
			is_firing_projectile = true
		)
#END: set_is_waiting_timer


#ANCHOR: set_is_firing_projectile_start
func set_is_firing_projectile(value: bool) -> void:
	is_firing_projectile = value
	if is_firing_projectile == true:
#END: set_is_firing_projectile_start
		var projectile: Projectile3D = projectile_scene.instantiate()
		add_sibling(projectile)
		projectile.global_position = shooting_point.global_position
		projectile.look_at(shooting_point.global_position + shooting_point.global_basis.z)

		is_firing_projectile = false
		is_looking_at_player = true
