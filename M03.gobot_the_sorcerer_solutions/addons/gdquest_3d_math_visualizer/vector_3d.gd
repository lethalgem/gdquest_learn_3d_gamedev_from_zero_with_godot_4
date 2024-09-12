@tool
class_name Vector3D extends Node3D

@export var vector := Vector3.UP:
	set(new_vector):
		vector = new_vector
		if not is_inside_tree() or vector.is_zero_approx():
			return

		_stem.mesh.height = vector.length() - pointer_height
		_stem.position.y = 0.5 * _stem.mesh.height
		_pointer.position.y = _stem.mesh.height + 0.5 * pointer_height

		_pivot.rotation = Vector3.ZERO
		if vector.abs().normalized().is_equal_approx(Vector3.UP):
			if vector.sign().y < 0.0:
				_pivot.rotation.z = PI
		else:
			var rotate_axis := Vector3.UP.cross(vector).normalized()
			_pivot.rotate(rotate_axis, Vector3.UP.angle_to(vector))

@export_category("Cosmetics")
@export var color := Color.WHITE:
	set(new_color):
		color = new_color
		if not is_inside_tree():
			return
		_stem.mesh.surface_get_material(0).albedo_color = color

@export_range(0.001, 1.0, 0.001, "or_greater", "suffix:m") var stem_radius := 0.05:
	set(new_stem_radius):
		stem_radius = new_stem_radius
		if not is_inside_tree():
			return
		_stem.mesh.top_radius = stem_radius
		_stem.mesh.bottom_radius = _stem.mesh.top_radius

@export_range(0.001, 1.0, 0.001, "or_greater", "suffix:m") var pointer_radius := 0.1:
	set(new_pointer_radius):
		pointer_radius = new_pointer_radius
		if not is_inside_tree():
			return
		_pointer.mesh.bottom_radius = pointer_radius

@export_range(0.001, 1.0, 0.001, "or_greater", "suffix:m") var pointer_height := 0.3:
	set(new_pointer_height):
		if new_pointer_height > vector.length():
			return

		pointer_height = new_pointer_height
		if not is_inside_tree():
			return
		_pointer.mesh.height = pointer_height
		_pointer.position.y = _stem.mesh.height + 0.5 * pointer_height
		vector = vector

var _pivot := Node3D.new()
var _stem := MeshInstance3D.new()
var _pointer := MeshInstance3D.new()


func _ready() -> void:
	add_child(_pivot)
	_pivot.add_child(_stem)
	_pivot.add_child(_pointer)

	_stem.mesh = CylinderMesh.new()

	var material := StandardMaterial3D.new()
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_stem.mesh.surface_set_material(0, material)

	_pointer.mesh = CylinderMesh.new()
	_pointer.mesh.top_radius = 0.0
	_pointer.mesh.surface_set_material(0, _stem.mesh.material)

	stem_radius = stem_radius
	color = color
	pointer_radius = pointer_radius
	pointer_height = pointer_height
	vector = vector


func _get_aabb() -> AABB:
	return _pointer.get_aabb().merge(_stem.get_aabb())
