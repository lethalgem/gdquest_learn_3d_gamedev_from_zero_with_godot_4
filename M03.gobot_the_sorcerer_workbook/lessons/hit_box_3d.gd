@tool
@icon("res://assets/icons/hit_box_3d.svg")
class_name HitBox3D extends Area3D

## Emitted when the hit box hits a hurt box.
signal hit_hurt_box(hurt_box: HurtBox3D)

const DAMAGE_SOURCE_PLAYER := 0b01
const DAMAGE_SOURCE_MOB := 0b10

@export var damage := 1
@export_flags("Player", "Mob") var damage_source := DAMAGE_SOURCE_PLAYER: set = set_damage_source

func set_damage_source(new_value: int) -> void:
	damage_source = new_value
	collision_layer = damage_source

@export_flags("Player", "Mob") var detected_hurtboxes := DAMAGE_SOURCE_MOB: set = set_detected_hurtboxes

func set_detected_hurtboxes(new_value: int) -> void:
	detected_hurtboxes = new_value
	collision_mask = detected_hurtboxes

func _init() -> void:
	monitoring = true
	monitorable = true
	area_entered.connect(func _on_area_entered(area: Area3D) -> void:
		if area is HurtBox3D:
			hit_hurt_box.emit(area)
	)
