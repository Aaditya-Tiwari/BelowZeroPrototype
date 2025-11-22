extends Node3D

@export var start_time_seconds: int = 60  # starting time (e.g., 60s)

var time_left: float
var running: bool = false

@onready var label: Label3D = $Label3D

func _ready():
	time_left = start_time_seconds
	update_label()
	# If you want it to auto start:
	# running = true

func _process(delta: float) -> void:
	if running and time_left > 0.0:
		time_left -= delta
		if time_left < 0.0:
			time_left = 0.0
			running = false
		update_label()
	
	face_player()

func update_label() -> void:
	var total_seconds := int(round(time_left))
	var minutes := total_seconds / 60
	var seconds := total_seconds % 60
	label.text = "%02d:%02d" % [minutes, seconds]

func face_player() -> void:
	var cam := get_viewport().get_camera_3d()
	if cam:
		look_at(cam.global_transform.origin, Vector3.UP)

func start_timer():
	time_left = start_time_seconds
	running = true

func stop_timer():
	running = false
