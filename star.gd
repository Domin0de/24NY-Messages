extends StaticBody3D

@export var hooked := false
@export var star_owner := ""

var player : CharacterBody3D

@onready var timer : Timer = $Timer
@onready var star_material : Material = $Pivot/star/Circle.get_surface_override_material(0)

func _ready() -> void:
	player = get_node("../Player")

func _physics_process(delta: float) -> void:
	if hooked:
		var original_y := global_position.y
		var closer := global_position + (player.global_position - global_position) / 10
		closer.y = original_y
		global_position = lerp(global_position, closer, 0.1)

func _process(delta: float) -> void:
	if player.owner_code == star_owner and timer.is_stopped():
		timer.start(1)
		star_material.set_feature(0, !star_material.get_feature(0)) # 0 = FEATURE_EMISSION
