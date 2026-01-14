extends RigidBody3D
class_name Player
var startFuel := 100
@onready var player: Node3D = $"."
@export_range(750, 2500) var engineForce := 1400.0
@export var SASens := 500.0
var trans := false
@onready var success_audio: AudioStreamPlayer = $SuccessAudio
@onready var explosion_audio: AudioStreamPlayer = $ExplosionAudio
@onready var main_thrust: AudioStreamPlayer = $MainThrust
@onready var main_particles: GPUParticles3D = $MainParticles
@onready var right_booster: GPUParticles3D = $RightBooster
@onready var left_booster: GPUParticles3D = $LeftBooster
@onready var explosion_particles: GPUParticles3D = $ExplosionParticles
@onready var success_particles: GPUParticles3D = $SuccessParticles
#
var ui : CanvasLayer 
@export var fuel : float : 
	set(new_fuel):
		fuel = new_fuel
		ui.updateFuel(new_fuel)
func _ready() -> void:
	ui = get_tree().get_first_node_in_group("UI")
	fuel = startFuel

func _process(delta: float) -> void:
	if !trans:
		if (Input.is_action_pressed("boost") && fuel>0):
			apply_central_force(basis.y * delta * engineForce*1.2)
			fuel -=.1
			if !(main_thrust.is_playing()):
				main_particles.emitting = true
				main_thrust.play()
		else:
			main_particles.emitting = false
			main_thrust.stop()
		if (Input.is_action_pressed("r_left")):
			apply_torque(Vector3(0,0,delta * SASens))
			apply_central_force(basis.y * delta * engineForce/5)
			right_booster.emitting = true
			fuel -=.05
		else:
			right_booster.emitting = false
		if (Input.is_action_pressed("r_right")):
			apply_torque(Vector3(0,0,-delta * SASens))
			apply_central_force(basis.y * delta * engineForce/5)
			left_booster.emitting = true
			fuel -=.05
		else:
			left_booster.emitting = false
			
func _on_body_entered(body: Node) -> void:
	if !trans:
		if "goal" in body.get_groups():
			if body.file_path:
				_complete_level(body.file_path)
			else:
				print("ERR 01: NO NEXT FILE PATH FOUND")
		if "terrain" in body.get_groups():
			_crash_sequence()

func _crash_sequence() -> void:
	explosion_audio.play()
	explosion_particles.emitting = true
	trans = true
	await get_tree().create_timer(1).timeout
	print("yes Rico, Kaboom.")
	get_tree().reload_current_scene.call_deferred()
	main_particles.emitting = false
	main_thrust.stop()
func _complete_level(next_level_file) -> void:
	main_particles.emitting = false
	success_particles.emitting = true
	main_thrust.stop()
	success_audio.play()
	trans = true
	print("u winned")
	await get_tree().create_timer(1).timeout
	get_tree().change_scene_to_file.call_deferred(next_level_file)
	
