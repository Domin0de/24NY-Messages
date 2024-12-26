extends CharacterBody3D

@export var speed := 10
@export var gravity := 20
@export var jump_speed := 10
@export var sensitivity := 500
@export var owner_code := ""

var cam_move := false
var target_instance: Node3D
var hook_instance: Node3D
var rope_instance: Node3D

@onready var hook_cast := $Pivot/Hook/Hook_Cast
@onready var timer: Timer = $Pivot/Hook/Timer

const hook_target = preload("res://hook_target.scn")
const hook_piece = preload("res://hook_piece.scn")
const hook_projectile = preload("res://hook_projectile.scn")

func _ready():
	target_instance = hook_target.instantiate()

	reset_target_instance()
	
func get_player():
	var err = 0
	var http = HTTPClient.new()

	err = http.connect_to_host("www.wolfdragon.me", 80) # Connect to host/port.
	assert(err == OK) # Make sure connection is OK.

	# Wait until resolved and connected.
	while http.get_status() == HTTPClient.STATUS_CONNECTING or http.get_status() == HTTPClient.STATUS_RESOLVING:
		http.poll()
		print("Connecting...")
		await get_tree().process_frame

	assert(http.get_status() == HTTPClient.STATUS_CONNECTED) # Check if the connection was made successfully.

	# Some headers
	var headers = [
		"User-Agent: Pirulo/1.0 (Godot)",
		"Accept: */*"
	]

	err = http.request(HTTPClient.METHOD_GET, "/cur_player", headers) # Request a page from the site (this one was chunked..)
	assert(err == OK) # Make sure all is OK.

	while http.get_status() == HTTPClient.STATUS_REQUESTING:
		# Keep polling for as long as the request is being processed.
		http.poll()
		print("Requesting...")
		await get_tree().process_frame

	assert(http.get_status() == HTTPClient.STATUS_BODY or http.get_status() == HTTPClient.STATUS_CONNECTED) # Make sure request finished well.

	print("response? ", http.has_response()) # Site might not have a response.

	if http.has_response():
		# If there is a response...

		headers = http.get_response_headers_as_dictionary() # Get response headers.
		print("code: ", http.get_response_code()) # Show response code.
		print("**headers:\\n", headers) # Show headers.

		# Getting the HTTP Body

		if http.is_response_chunked():
			# Does it use chunks?
			print("Response is Chunked!")
		else:
			# Or just plain Content-Length
			var bl = http.get_response_body_length()
			print("Response Length: ", bl)

		# This method works for both anyway

		var rb = PackedByteArray() # Array that will hold the data.

		while http.get_status() == HTTPClient.STATUS_BODY:
			# While there is body left to be read
			http.poll()
			# Get a chunk.
			var chunk = http.read_response_body_chunk()
			if chunk.size() == 0:
				await get_tree().process_frame
			else:
				rb = rb + chunk # Append to read buffer.
		# Done!

		print("bytes got: ", rb.size())
		var text = rb.get_string_from_ascii()
		print("Text: ", text)

func _physics_process(delta):
	get_move_input(delta)

	move_and_slide()
	
	if Input.is_action_pressed("jump"):
		velocity.y = jump_speed

	if not is_on_floor():
		velocity.y -= (gravity * delta * 1/2)

func _input(event):
	if event is InputEventMouseMotion and cam_move:
		rotation.x -= event.relative.y / sensitivity
		rotation_degrees.x = clamp(rotation_degrees.x, -90.00, 80)
		rotation.y -= event.relative.x / sensitivity
		
	if Input.is_action_pressed("aim"):
		cam_move = true

		project_aim()
	else:
		cam_move = false
		reset_target_instance()
		
	if timer.is_stopped() and Input.is_action_just_pressed("shoot"):
		timer.start(0.1)
		shoot_hook()

func reset_target_instance():
	if target_instance.global_position.y != -1000:
		target_instance.global_position.y = -1000

func get_move_input(_delta):
	var stored_y = velocity.y
	velocity.y = 0

	var input = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = Vector3(input.x, 0, input.y).rotated(Vector3.UP, rotation.y)

	velocity = lerp(velocity, direction * speed, 0.5)
	velocity.y = stored_y

func project_aim(target_casting = true):
	if hook_cast.is_colliding():
		var collision = hook_cast.get_collision_point()
		var normal = hook_cast.get_collision_normal()
		var target = hook_cast.get_collider()

		if target != null:
			if target_casting:
				get_tree().current_scene.add_child(target_instance)
				target_instance.global_position = collision

				target_instance.look_at(collision + normal, Vector3.UP)
				target_instance.look_at(collision + normal, Vector3.RIGHT)

			return {"collision": collision, "normal": normal, "target": target}

	reset_target_instance()
	return {}

func shoot_hook():
	var shoot_attempt = project_aim(false)
	print("Made shoot attempt", shoot_attempt)

	if shoot_attempt != {} and shoot_attempt['target'].name == "Star":
		# Hide player hook piece if shot
		$Pivot/Hook/Pivot/Hook_Piece.visible = false
		
		cleanup_hook_projectile()

		# Create a new hook instance and add it to the hook as a child
		hook_instance = hook_projectile.instantiate()
		$Pivot/Hook.add_child(hook_instance)
		hook_instance.global_transform = $Pivot/Hook.global_transform
		hook_instance.target_pos = shoot_attempt['collision']
		
		#create_hook_rope(shoot_attempt['target'])
		return

	cleanup_hook_projectile()
	$Pivot/Hook/Pivot/Hook_Piece.visible = true

func cleanup_hook_projectile():
	# If another hook instance exists, hide and delete it
	if hook_instance:
		hook_instance.global_position.y = -1000
		$Pivot/Hook.remove_child(hook_instance)
		
		if hook_instance.collision_star:
			hook_instance.collision_star.hooked = false

		hook_instance.queue_free()
		hook_instance = null

#func create_hook_rope(target: Node3D):
	#rope_instance = rope.instantiate()
	#$Pivot/Hook.add_child(rope_instance)
	#rope_instance.startpoint = $Pivot/Hook
	#rope_instance.endpoint = target

func cleanup_hook_rope():
	pass
