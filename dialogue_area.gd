extends Area3D

var area_active := false

@onready var dialogue_player := get_node("../UI/Dialogue")
@onready var pos = global_position
@onready var timer: Timer = $Timer

var min_v = .0001
var max_v = .001

func _physics_process(delta: float) -> void:
	global_position = pos + Vector3(randf_range(min_v, max_v), randf_range(min_v, max_v), randf_range(min_v, max_v))

func _input(event: InputEvent) -> void:
	if timer.is_stopped() and area_active and event.is_action_released("ui_accept"):
		dialogue_player.display_line(true)


func _on_body_entered(body: Node3D) -> void:
	area_active = true


func _on_body_exited(body: Node3D) -> void:
	area_active = false
