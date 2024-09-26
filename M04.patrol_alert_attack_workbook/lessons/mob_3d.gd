class_name Mob3D extends Node

## The mob's skin. This is necessary to play animations.
@export var skin: MobSkin3D = null
## The mob's hurtbox. This is necessary for managing damage.
@export var hurt_box: HurtBox3D = null

@export_category("Detection")
## Determines how far the mob can detect the player.
@export var vision_range := 7.0
## Detemines the angle in radians that the mob can detect the player.
@export_range(0.0, 360.0, 0.1, "radians_as_degress") var vision_angle := PI / 4.0

@export_category("Debugging")
@export var debug_label: Label3D = null
