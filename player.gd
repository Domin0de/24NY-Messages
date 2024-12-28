extends CharacterBody3D

@export var speed := 10
@export var gravity := 20
@export var jump_speed := 10
@export var sensitivity := 500

var cam_move := false
var aim_triggered := false
var target_instance: Node3D
var hook_instance: Node3D
var rope_instance: Node3D

@onready var hook_cast := $Pivot/Hook/Hook_Cast
@onready var timer: Timer = $Pivot/Hook/Timer

@onready var _crosshair : TextureRect = $"../UI/Crosshair"

const hook_target = preload("res://hook_target.scn")
const hook_piece = preload("res://hook_piece.scn")
const hook_projectile = preload("res://hook_projectile.scn")

func _ready():
	target_instance = hook_target.instantiate()
	target_instance.transform.origin.y = -1000

	if OS.get_name()=="Web":
		Global.owner_code = JavaScriptBridge.eval("id")
		print("Got owner code ", Global.owner_code)

func _physics_process(delta):
	get_move_input(delta)

	move_and_slide()
	
	if Input.is_action_pressed("jump"):
		velocity.y = jump_speed

	if not is_on_floor():
		velocity.y -= (gravity * delta * 1/2)
		
	if is_on_floor():
		velocity.y = 0

func _unhandled_input(event):
	if event is InputEventMouseMotion and cam_move:
		rotation.x -= event.relative.y / sensitivity
		rotation_degrees.x = clamp(rotation_degrees.x, -90.00, 80)
		rotation.y -= event.relative.x / sensitivity
		
	if Input.is_action_pressed("aim"):
		cam_move = true
		aim_triggered = true
		_crosshair.visible = true

		project_aim()
	elif aim_triggered:
		aim_triggered = false
		cam_move = false
		_crosshair.visible = false
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
	velocity.y = stored_y + 0.01

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
