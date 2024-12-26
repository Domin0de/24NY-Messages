extends RayCast3D

@export var speed := 50.0

var target_pos = null
var positioned := false
var pos_diff = null
@export var collision_star : Node3D = null

func _physics_process(delta: float) -> void:
	if not collision_star:
		if not positioned:
			look_at(target_pos)
			positioned = true

		var forward_motion := Vector3.FORWARD * speed * delta
		position += global_basis * forward_motion
		target_position = forward_motion
		force_raycast_update()

		if is_colliding():
			global_position = get_collision_point()

			collision_star = get_collider()
			collision_star.hooked = true
			
			pos_diff = self.global_position - collision_star.global_position
	else:
		global_position = collision_star.global_position + pos_diff
