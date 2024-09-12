#ANCHOR:tool
@tool
#END:tool
#ANCHOR:icon
@icon("res://assets/icons/hit_box_3d.svg")
#END:icon
#ANCHOR:class_name
class_name HitBox3D extends Area3D
#END:class_name

#ANCHOR:signal_hit_hurt_box
## Emitted when the hit box hits a hurt box.
signal hit_hurt_box(hurt_box: HurtBox3D)
#END:signal_hit_hurt_box

#ANCHOR:const_source
const DAMAGE_SOURCE_PLAYER := 0b01
const DAMAGE_SOURCE_MOB := 0b10
#END:const_source

## The amount of damage the hit box deals.
#ANCHOR:var_damage
@export var damage := 1
#END:var_damage
## The type of damage that the hit box deals. This helps hurt boxes to filter out damage types.
#ANCHOR:var_damage_source
@export_flags("Player", "Mob") var damage_source := DAMAGE_SOURCE_PLAYER: set = set_damage_source
#END:var_damage_source
#ANCHOR:var_detected_hurtboxes
@export_flags("Player", "Mob") var detected_hurtboxes := DAMAGE_SOURCE_MOB: set = set_detected_hurtboxes
#END:var_detected_hurtboxes

#ANCHOR:func_init
func _init() -> void:
	monitoring = true
	monitorable = true
	area_entered.connect(func _on_area_entered(area: Area3D) -> void:
		if area is HurtBox3D:
			hit_hurt_box.emit(area)
	)
#END:func_init


#ANCHOR:func_set_damage_source
func set_damage_source(new_value: int) -> void:
	damage_source = new_value
	collision_layer = damage_source
#END:func_set_damage_source


#ANCHOR:func_set_detected_hurtboxes
func set_detected_hurtboxes(new_value: int) -> void:
	detected_hurtboxes = new_value
	collision_mask = detected_hurtboxes
#END:func_set_detected_hurtboxes
