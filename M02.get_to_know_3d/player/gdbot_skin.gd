class_name CharacterSkin extends Node3D

signal foot_step

var moving_blend_path := "parameters/StateMachine/move/blend_position"

## Changes the character animation between run and idle.
var is_moving := false: set = set_moving
## When toggled, animates the character aiming or not aiming.
var is_aiming := false : set = set_is_aiming

## Reference to a point in the character's hand. You can use it to place an object in the character's hand or spawn a projectile.
@onready var hand_anchor: Marker3D = %HandAnchor

@onready var _animation_tree: AnimationTree = $AnimationTree
@onready var _state_machine: AnimationNodeStateMachinePlayback = _animation_tree.get("parameters/StateMachine/playback")


func _ready() -> void:
	_animation_tree.active = true


func set_is_aiming(new_state: bool) -> void:
	if is_aiming == new_state:
		return
	is_aiming = new_state
	var tween := create_tween()
	tween.tween_property(_animation_tree, "parameters/AimBlend/blend_amount", float(is_aiming), 0.1)


func set_moving(value: bool) -> void:
	is_moving = value
	if is_moving:
		_state_machine.travel("run")
	else:
		_state_machine.travel("idle")


func jump() -> void:
	_state_machine.travel("jump")


func fall() -> void:
	_state_machine.travel("fall")


func play_victory_animation() -> void:
	_state_machine.travel("victory_entry")
	set_is_aiming(false)
