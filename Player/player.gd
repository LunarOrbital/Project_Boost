extends RigidBody3D
class_name Player
@onready var player: Node3D = $"."
@export_range(750, 2500) var engineForce := 1400.0
@export var SASens := 500.0
var trans := false
@onready var success_audio: AudioStreamPlayer = $SuccessAudio
@onready var explosion_audio: AudioStreamPlayer = $ExplosionAudio
@onready var main_thrust: AudioStreamPlayer = $MainThrust


func _ready() -> void:
	print("ahh")

func _process(delta: float) -> void:
	if !trans:
		if (Input.is_action_pressed("boost")):
			apply_central_force(basis.y * delta * engineForce)
			if !(main_thrust.is_playing()):
				main_thrust.play()
			else:
				main_thrust.stop()
		if (Input.is_action_pressed("r_left")):
			apply_torque(Vector3(0,0,delta * SASens))
		if (Input.is_action_pressed("r_right")):
			apply_torque(Vector3(0,0,-delta * SASens))


func _on_body_entered(body: Node) -> void:
	print(body)
	if !trans:
		if "goal" in body.get_groups():
			if body.file_path:
				_complete_level(body.file_path)
			else:
				print("ERR 01: NO NEXT FILE PATH FOUND")
		if "terrain" in body.get_groups():
			_crash_sequence()

func _crash_sequence() -> void:
	trans = trans
	await get_tree().create_timer(1).timeout
	print("yes Rico, Kaboom.")
	get_tree().reload_current_scene.call_deferred()
	explosion_audio.play()
func _complete_level(next_level_file) -> void:
	success_audio.play()
	trans = true
	print("u winned")
	await get_tree().create_timer(1).timeout
	get_tree().change_scene_to_file.call_deferred(next_level_file)
	
