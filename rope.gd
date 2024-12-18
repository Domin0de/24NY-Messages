@tool
extends MeshInstance3D

@export var startpoint: Node3D
@export var endpoint: Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update(startpoint.global_position, endpoint.global_position)

func update(start: Vector3, end: Vector3) -> void:
	var trail: Vector3 = end - start
	var direction: Vector3 = trail.normalized()
	var distance: float = trail.length()
	var dir90: Vector3 = direction.rotated(Vector3.UP, TAU/4)

	var thickness: float = 4.0
	var points: int = 3

	mesh.clear_surfaces()

	mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)

	for i in range(0, points + 1):
		var x: float = float(i) / float(points)
		var d: Vector3 = (x * distance) * direction

		mesh.surface_set_normal(Vector3.UP)
		mesh.surface_set_uv(Vector2(1.0, x))
		mesh.surface_add_vertex(start + d - (thickness * dir90))

		mesh.surface_set_normal(Vector3.UP)
		mesh.surface_set_uv(Vector2(0.0, x))
		mesh.surface_add_vertex(start + d + (thickness * dir90))

	mesh.surface_end()
