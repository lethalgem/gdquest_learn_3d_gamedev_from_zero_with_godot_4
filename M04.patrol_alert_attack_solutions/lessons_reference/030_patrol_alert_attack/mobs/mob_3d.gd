## The base class for all mobs in the game.
## 
## It extends the [CharacterBody3D] class and adds the necessary nodes to manage
## the mob's skin and hurtbox. It also includes the base stats for the mob, such
## as health and damage.
#ANCHOR:extends
class_name Mob3D extends CharacterBody3D
#END:extends

#ANCHOR:export_nodes
## The mob's skin. This is necessary to play animations.
@export var skin: MobSkin3D = null
## The mob's hurtbox. This is necessary for managing damage.
@export var hurt_box: HurtBox3D = null
#END:export_nodes

#ANCHOR:export_debug
@export_category("Debugging")
@export var debug_label: Label3D = null
#END:export_debug

@export_category("Base Stats")
@export var max_health := 3
@export var damage := 1

#ANCHOR:export_detection
@export_category("Detection")
## Determines how far the mob can detect the player.
@export var vision_range := 7.0
## Determines the angle in radians that the mob can detect the player.
@export_range(0.0, 360.0, 0.1, "radians_as_degrees") var vision_angle := PI / 4.0
#END:export_detection

@export_category("Base Movement")
@export var drag_factor := 5.0
@export var max_speed := 10.0

var health := max_health


## Override it to define how the mob should die.
func deactivate() -> void:
	if hurt_box != null:
		(func deactivate_hurtbox():
			hurt_box.monitoring = false
			hurt_box.monitorable = false).call_deferred()
