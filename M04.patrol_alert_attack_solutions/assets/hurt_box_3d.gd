#ANCHOR:tool
@tool
#END:tool
#ANCHOR:icon
@icon("res://assets/icons/hurt_box_3d.svg")
#END:icon
#ANCHOR:class_name
class_name HurtBox3D extends Area3D
#END:class_name

#ANCHOR:signal_took_hit
signal took_hit(hit_box: HitBox3D)
#END:signal_took_hit

#ANCHOR:const_damage_source
const DAMAGE_SOURCE_PLAYER := 0b01
const DAMAGE_SOURCE_MOB := 0b10
#END:const_damage_source

## Controls which damage source the hurt box can take damage from.
## This changes the node's collision mask so it will only collide with a matching damage source.
#ANCHOR:var_damage_source
@export_flags("Player", "Mob") var damage_source := DAMAGE_SOURCE_PLAYER: set = set_damage_source
#END:var_damage_source
#ANCHOR:var_hurtbox_type
@export_flags("Player", "Mob") var hurtbox_type := DAMAGE_SOURCE_PLAYER: set = set_hurtbox_type
#END:var_hurtbox_type


#ANCHOR:func_init
func _init() -> void:
	monitoring = true
	monitorable = true
	area_entered.connect(func _on_area_entered(area: Area3D) -> void:
		if area is HitBox3D:
			took_hit.emit(area)
	)
#END:func_init

#ANCHOR:func_set_damage_source
func set_damage_source(new_value: int) -> void:
	damage_source = new_value
	collision_mask = damage_source
#END:func_set_damage_source

#ANCHOR:func_set_hurtbox_type
func set_hurtbox_type(new_value: int) -> void:
	hurtbox_type = new_value
	collision_layer = hurtbox_type
#END:func_set_hurtbox_type
