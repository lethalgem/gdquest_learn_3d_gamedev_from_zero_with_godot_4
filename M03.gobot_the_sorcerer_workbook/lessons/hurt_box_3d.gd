@tool
@icon("res://assets/icons/hurt_box_3d.svg")
class_name HurtBox3D extends Area3D

## Emitted when the hit box hits a hurt box.
signal took_hit(hit_box: HitBox3D)

const DAMAGE_SOURCE_PLAYER := 0b01
const DAMAGE_SOURCE_MOB := 0b10

@export var damage := 1
@export_flags("Player", "Mob") var damage_source := DAMAGE_SOURCE_PLAYER: set = set_damage_source

func set_damage_source(new_value: int) -> void:
	damage_source = new_value
	collision_mask = damage_source

@export_flags("Player", "Mob") var hurtbox_type := DAMAGE_SOURCE_MOB: set = set_hurtbox_type

func set_hurtbox_type(new_value: int) -> void:
	hurtbox_type = new_value
	collision_layer = hurtbox_type

func _init() -> void:
	monitoring = true
	monitorable = true
	area_entered.connect(func _on_area_entered(area: Area3D) -> void:
		if area is HitBox3D:
			took_hit.emit(area)
	)
