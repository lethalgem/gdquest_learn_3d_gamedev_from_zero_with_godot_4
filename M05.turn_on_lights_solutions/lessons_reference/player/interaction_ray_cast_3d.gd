## Allows the player to interact with objects in the scene using a raycast.
## The length of the ray determines from where the player can interact with
## objects.
class_name InteractionRayCast3D extends RayCast3D

var _focused_node: Interactable3D = null


func _init() -> void:
	enabled = false

	collide_with_bodies = false
	collide_with_areas = true


func _unhandled_input(event: InputEvent) -> void:
	if _focused_node != null and event.is_action_pressed("interact"):
		_focused_node.interact()


func _physics_process(_delta: float) -> void:
	#ANCHOR: l7_poll_collider
	force_raycast_update()
	var collider := get_collider() as Interactable3D
	#END: l7_poll_collider

	#ANCHOR: l7_highlight_remove
	if collider == null and _focused_node != null:
		_focused_node.is_highlighted = false
		#END: l7_highlight_remove

	#ANCHOR: l7_set_focused_node
	_focused_node = collider
	#END: l7_set_focused_node
	#ANCHOR: l7_highlight_add
	if _focused_node != null:
		_focused_node.is_highlighted = true
		#END: l7_highlight_add
