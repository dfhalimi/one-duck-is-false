class_name DuckMovement
extends Node

@export var speed: float = 1.0
@export var wander_radius: float = 3.0
@export var time_between_moves: float = 2.0
@export var body: CharacterBody3D
@export var animator: AnimationPlayer

@onready var player = get_node_or_null("/root/Main/Player")

var spawn_origin: Vector3 = Vector3.ZERO
var target_pos: Vector3 = Vector3.ZERO

var is_staring: bool = false

var move_timer: float = 0.0
var stare_timer: float = 0.0

func _ready() -> void:
	spawn_origin = body.global_position
	pick_new_target()
	
func update_movement(delta) -> void:
	if is_staring:
		stare_timer -= delta

		if player:
			var duck_pos = body.global_position
			var player_pos = player.global_position
			player_pos.y = duck_pos.y  # flatten look target to avoid tilting

			var dir = (player_pos - duck_pos).normalized()
			var target_angle = atan2(-dir.x, -dir.z)
			var current_angle = body.rotation.y
			var new_angle = lerp_angle(current_angle, target_angle, delta * 3.5)  # smooth turning

			body.rotation.y = new_angle

		if stare_timer <= 0.0:
			is_staring = false
			var rot = body.rotation
			var pos = body.position
			body.rotation = Vector3(0, rot.y, 0)
			body.position = Vector3(pos.x, 0, pos.z)

		return
		
	move_timer -= delta

	if body.global_position.distance_squared_to(target_pos) < 0.1 or move_timer <= 0:
		pick_new_target()

	var move_dir = (target_pos - body.global_position).normalized()
	body.velocity.x = move_dir.x * speed
	body.velocity.z = move_dir.z * speed

	if move_dir.length_squared() > 0.01:
		body.look_at(body.global_position + move_dir, Vector3.UP)

	if body.velocity.length_squared() > 0.01:
		if not animator.is_playing() or animator.current_animation != "walkcycle_1":
			animator.play("walkcycle_1")
	else:
		if animator.is_playing():
			animator.stop()
			
	if not is_staring and body.brain.traits.has(DuckBrain.Trait.STARES_AT_PLAYER):
		if randi() % 500 == 0:
			start_staring()

func pick_new_target() -> void:
	move_timer = time_between_moves
	var rand_offset = Vector3(
		randf_range(-wander_radius, wander_radius),
		0,
		randf_range(-wander_radius, wander_radius)
	)
	target_pos = spawn_origin + rand_offset

func set_new_spawn_origin() -> void:
	spawn_origin = body.global_position
	
func start_staring():
	is_staring = true
	stare_timer = randf_range(2.0, 4.0)

	if player:
		body.look_at(player.global_transform.origin, Vector3.UP)

	body.velocity = Vector3.ZERO
	animator.stop()
