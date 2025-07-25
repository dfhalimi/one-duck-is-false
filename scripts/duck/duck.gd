class_name Duck
extends CharacterBody3D

@onready var brain: DuckBrain = $DuckBrain
@onready var interaction: DuckInteraction = $DuckInteraction
@onready var mover: DuckMovement = $DuckMovement
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var animator: AnimationPlayer = $DuckModelPlaceholder/AnimationPlayer

@onready var brush_audio: AudioStreamPlayer3D = $BrushAudio
@onready var pet_audio: AudioStreamPlayer3D = $PetAudio
@onready var laugh_audio: AudioStreamPlayer3D = $LaughAudio
@onready var quack_audio: AudioStreamPlayer3D = $QuackAudio
@onready var munch_audio: AudioStreamPlayer3D = $MunchAudio

@onready var quack_timer: Timer = $QuackTimer

var min_quack_interval := 8.0
var max_quack_interval := 40.0

var duck_name: String:
	get: return brain.duck_name
	set(value): brain.duck_name = value
	
var is_false_duck: bool:
	get: return brain.is_false_duck
	set(value): brain.is_false_duck = value
	
func _ready() -> void:
	set_new_spawn_origin()
	randomize()
	_start_quack_cycle()

func _on_quack_timer_timeout():
	if not is_being_held():
		quack_audio.pitch_scale = randf_range(0.9, 1.1)
		quack_audio.play()

	_start_quack_cycle()

func _start_quack_cycle():
	var next_quack_time = randf_range(min_quack_interval, max_quack_interval)
	quack_timer.wait_time = next_quack_time
	quack_timer.start()

func _physics_process(delta) -> void:
	if brain.is_dead:
		return
	mover.update_movement(delta)
	move_and_slide()
		
func die() -> void:
	brain.is_dead = true
	set_physics_process(false)
	set_process(false)
	collision_shape_3d.disabled = true

func pet() -> void: 
	interaction.pet()
	pet_audio.play()

func tickle() -> void: 
	interaction.tickle()
	laugh_audio.pitch_scale = randf_range(0.9, 1.1)
	laugh_audio.play()
	
func feed() -> void: 
	interaction.feed()
	munch_audio.pitch_scale = randf_range(0.9, 1.1)
	munch_audio.play()

func brush() -> void: 
	interaction.brush()
	brush_audio.pitch_scale = randf_range(0.9, 1.1)
	brush_audio.play()

func bathe() -> void: interaction.bathe()
func accuse() -> void: interaction.accuse()

func set_new_spawn_origin() -> void:
	mover.set_new_spawn_origin()
	
func is_being_held() -> bool:
	return get_parent().name == "DuckHoldPoint"
