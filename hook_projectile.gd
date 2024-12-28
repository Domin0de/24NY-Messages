extends RayCast3D

@export var speed := 50.0

var target_pos = null
var positioned := false
var pos_diff = null
@export var collision_star : Node3D = null
@onready var owner_code: String = Global.owner_code

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
			if collision_star.star_owner == owner_code:
				collision_star.hooked = true

				pos_diff = self.global_position - collision_star.global_position
				Global.dialogue.single_line("This seems to hold some memories, try bring it to Cinnamoroll and interact with him...")
			else:
				collision_star = null
	else:
		global_position = collision_star.global_position + pos_diff
