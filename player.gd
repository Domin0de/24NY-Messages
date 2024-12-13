extends CharacterBody3D

@export var speed = 10
@export var gravity = 20
@export var jump_speed = 10
@export var sensitivity = 500

var cam_move = false
@onready var spring_arm = $SpringArm3D

func _physics_process(delta):
	get_move_input(delta)

	move_and_slide()
	
	if Input.is_action_pressed("jump"):
		velocity.y = jump_speed

	if Input.is_action_pressed("aim"):
		cam_move = true
		
		
	else:
		cam_move = false

	if not is_on_floor():
		velocity.y -= (gravity * delta * 1/2)

func get_move_input(delta):
	var stored_y = velocity.y
	velocity.y = 0

	var input = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = Vector3(input.x, 0, input.y).rotated(Vector3.UP, rotation.y)

	velocity = lerp(velocity, direction * speed, 0.5)
	velocity.y = stored_y

func _input(event):
	if event is InputEventMouseMotion and cam_move:
		rotation.x -= event.relative.y / sensitivity
		rotation_degrees.x = clamp(rotation_degrees.x, -90.00, 30)
		rotation.y -= event.relative.x / sensitivity
		
	if event.is_action_pressed("shoot"):
		pass
