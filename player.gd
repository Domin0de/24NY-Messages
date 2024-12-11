extends CharacterBody3D

@export var speed = 8
@export var gravity_acceleration = 20
@export var jump_speed = 8

var target_velocity = Vector3.ZERO

func _physics_process(delta: float) -> void:
	var direction = Vector3.ZERO

	# Set direction relative to base axes relative to inputs
	if Input.is_action_pressed("move_forward"):
		direction.z -= 1
	if Input.is_action_pressed("move_back"):
		direction.z += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_right"):
		direction.x += 1

	if Input.is_action_pressed("jump"):
		target_velocity.y = jump_speed

	if direction != Vector3.ZERO:
		direction = direction.normalized()
		$Pivot.basis = Basis.looking_at(direction)

	target_velocity.x = direction.x * speed
	target_velocity.z = direction.z * speed

	if not is_on_floor():
		target_velocity.y -= (gravity_acceleration * delta * 1/2)

	velocity = target_velocity
	move_and_slide()

	# Match position and facing of camera follower with self
	$Camera_Follower.position = lerp($Camera_Follower.position, position, 0.1)
