extends RayCast3D

@export var speed := 50.0

var target_pos = null
var positioned := false

func _physics_process(delta: float) -> void:
	if not positioned:
		look_at(target_pos)
		positioned = true

	var forward_motion := Vector3.FORWARD * speed * delta
	position += global_basis * forward_motion
	target_position = forward_motion
	force_raycast_update()

	if is_colliding():
		global_position = get_collision_point()
		set_physics_process(false)
