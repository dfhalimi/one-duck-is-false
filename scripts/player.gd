class_name Player
extends CharacterBody3D

@export var mouse_sensitivity := 0.002
@export var move_speed := 5.0
@export var jump_velocity := 4.0

@export_group("Headbob")
@export var headbob_frequency: float = 2.0
@export var headbob_amplitude: float = 0.04
var headbob_time: float = 0.0

@export_group("Footsteps")
@export_subgroup("Grass")
@export var grass_sounds: Array[AudioStream] = []
@export_subgroup("Wood")
@export var wood_sounds: Array[AudioStream] = []

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var ray: RayCast3D = $Head/Camera3D/RayCast3D
@onready var body_mesh: MeshInstance3D = $BodyMesh
@onready var floor_ray: RayCast3D = $FloorRay

@onready var interact_prompt_label: Label = get_tree().get_root().get_node("Main/UI/Control/InteractPrompt")

@onready var duck_hold_point: Node3D = $Head/Camera3D/DuckHoldPoint
@onready var object_hold_point: Node3D = $Head/Camera3D/ObjectHoldPoint

@onready var duck_pickup_audio: AudioStreamPlayer3D = $Head/Camera3D/DuckHoldPoint/DuckPickupAudio
@onready var duck_put_down_audio: AudioStreamPlayer3D = $DuckPutDownAudio
@onready var foot_step_audio: AudioStreamPlayer3D = $FootStepAudio

@onready var naming_panel: Panel = $"../UI/Control/NamingPanel"
@onready var name_input: LineEdit = $"../UI/Control/NamingPanel/NameInput"
@onready var confirm_button: Button = $"../UI/Control/NamingPanel/ConfirmButton"

@onready var food_tray: FoodTray = $"../FoodTray"
@onready var bath: Bath = $"../Bath"

signal has_fed_duck

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var y_velocity : float = 0.0
var pitch : float = 0.0
var current_zone: String = ""
var held_duck: Duck = null
var held_brush: Brush = null
var is_holding_food: bool = false
var in_bath_area: bool = false
var in_naming_window: bool = false

var footstep_can_play: bool = true
var footstep_landed

func _ready() -> void:
	body_mesh.visible = false
	for zone in get_tree().get_nodes_in_group("zones"):
		zone.player_entered_zone.connect(_on_player_entered_zone)
		zone.player_exited_zone.connect(_on_player_exited_zone)
	
	name_input.text_submitted.connect(_on_name_entered)
	food_tray.has_food_taken.connect(_on_has_food_taken)
	bath.has_put_duck_into_bath.connect(_on_duck_put_in_bath)
	bath.has_retrieved_duck_from_bath.connect(_on_duck_retrieved_from_bath)
	bath.player_entered_bath_area.connect(_on_player_entered_bath_area)
	bath.player_exited_bath_area.connect(_on_player_exited_bath_area)
	
func _process(_delta) -> void:
	# Suppress normal prompts if in bath area
	if in_bath_area or in_naming_window:
		interact_prompt_label.visible = false
		return
	# Priority: if holding a duck, show drop and contextual prompts
	if held_duck is Duck:
		interact_prompt_label.text = "[E] Tickle " + held_duck.duck_name + "\n[F] Put down " + held_duck.duck_name
		interact_prompt_label.visible = true
		return

	# Not holding a duck → check if you're aiming at one
	if ray.is_colliding():
		var hit: Object = ray.get_collider()

		if hit is Duck:
			var duck: Duck = hit
			var duck_name: String = duck.duck_name

			if is_holding_food:
				# Only show feed prompt when holding food
				interact_prompt_label.text = "[E] Feed " + duck_name
				interact_prompt_label.visible = true
				return
			elif held_brush:
				interact_prompt_label.text = "[E] Brush " + duck_name
				interact_prompt_label.visible = true
				return
			else:
				# Show both prompts when not holding food
				var action_prompt := "[E] Pet " + duck_name
				interact_prompt_label.text = action_prompt + "\n[F] Pick up " + duck_name
				interact_prompt_label.visible = true
				return

	# No valid duck target
	interact_prompt_label.visible = false

func _physics_process(delta) -> void:
	var direction: Vector3 = Vector3.ZERO

	if Input.is_action_pressed("move_forward"):
		direction -= transform.basis.z
	if Input.is_action_pressed("move_back"):
		direction += transform.basis.z
	if Input.is_action_pressed("move_left"):
		direction -= transform.basis.x
	if Input.is_action_pressed("move_right"):
		direction += transform.basis.x

	direction = direction.normalized()
	velocity.x = direction.x * move_speed
	velocity.z = direction.z * move_speed

	if not is_on_floor():
		y_velocity -= gravity * delta
	else:
		if Input.is_action_just_pressed("jump"):
			y_velocity = jump_velocity
		else:
			y_velocity = 0

	velocity.y = y_velocity
	move_and_slide()
	
	headbob_time += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = headbob()
	
	if (not footstep_landed and is_on_floor()) or (footstep_landed and not is_on_floor()):
		play_footstep_sound()
	footstep_landed = is_on_floor()
	
func _input(event) -> void:
	if event is InputEventMouseMotion:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		rotate_y(deg_to_rad(-event.relative.x * 0.05))
		head.rotate_x(deg_to_rad(-event.relative.y * 0.05))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-80), deg_to_rad(90))
		#rotate_y(-event.relative.x * mouse_sensitivity)
		#pitch = clamp(pitch - event.relative.y * mouse_sensitivity, deg_to_rad(-90), deg_to_rad(90))
		#camera.rotation.x = pitch

func _unhandled_input(event) -> void:
	if event.is_action_pressed("pick_up_drop"):
		if held_duck:
			drop_held_duck()
		elif ray.is_colliding() and not is_holding_food and not held_brush:
			var hit: Object = ray.get_collider()
			if hit is Duck and not held_duck:
				pick_up(hit)
	elif event.is_action_pressed("interact") and not in_bath_area:
		if held_duck:
			# Contextual action on held duck (e.g., tickle/brush)
			# For now, tickle as default
			held_duck.tickle()
		elif ray.is_colliding():
			var hit: Object = ray.get_collider()
			if hit is Duck:
				if is_holding_food:
					hit.feed()
					has_fed_duck.emit()
					is_holding_food = false
				elif held_brush:
					hit.brush()
				else:
					hit.pet()
				
func _on_player_entered_zone(context: int) -> void:
	match context:
		Zone3D.Context.LAKE:
			current_zone = "lake"
		Zone3D.Context.PEN:
			current_zone = "pen"
		Zone3D.Context.HOUSE:
			current_zone = "house"
		_:
			current_zone = ""
	print("Player has entered ", current_zone)

func _on_player_exited_zone(context: int) -> void:
	if current_zone != "":
		print("Player has left ", current_zone)
	match context:
		Zone3D.Context.LAKE:
			if current_zone == "lake":
				current_zone = ""
		Zone3D.Context.PEN:
			if current_zone == "pen":
				current_zone = ""
		Zone3D.Context.HOUSE:
			if current_zone == "house":
				current_zone = ""
				
func play_footstep_sound():
	if floor_ray.is_colliding():
		var ground = floor_ray.get_collider()
		var sound: AudioStream = null

		if ground.is_in_group("wood"):
			sound = wood_sounds.pick_random()
		elif ground.is_in_group("grass"):
			sound = grass_sounds.pick_random()

		if sound:
			foot_step_audio.stream = sound
			foot_step_audio.play()
				
func headbob() -> Vector3:
	var headbob_position = Vector3.ZERO
	headbob_position.y = sin(headbob_time * headbob_frequency) * headbob_amplitude
	headbob_position.x = cos(headbob_time * headbob_frequency / 2) * headbob_amplitude
	
	var footstep_threshold = -headbob_amplitude + 0.002
	if headbob_position.y > footstep_threshold:
		footstep_can_play = true
	elif headbob_position.y < footstep_threshold and footstep_can_play:
		footstep_can_play = false
		play_footstep_sound()
	
	return headbob_position
				
func pick_up(duck: Duck) -> void:
	if held_duck:
		print("Already holding " + duck.duck_name + "... Is that not enough for you?")
		return

	# Remove from old parent and add to player node
	if duck.get_parent():
		duck.get_parent().remove_child(duck)

	duck_hold_point.add_child(duck)
	held_duck = duck

	# Reset transform locally relative to hold point
	var original_scale = duck.scale
	duck.transform = Transform3D.IDENTITY
	duck.scale = original_scale
	duck.velocity = Vector3.ZERO
	duck.set_physics_process(false)
	duck.set_process(false)
	
	duck_pickup_audio.pitch_scale = randf_range(0.9, 1.1)
	duck_pickup_audio.play()

	# Only show naming panel if duck is unnamed
	if duck.brain.duck_name.strip_edges() == "":
		in_naming_window = true
		#interact_prompt_label.visible = false
		naming_panel.visible = true
		name_input.text = ""
		name_input.grab_focus()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		set_process_input(false)
		set_physics_process(false)
	
func drop_held_duck() -> void:
	if not held_duck:
		return

	# Remove from hold point and reparent to world
	duck_hold_point.remove_child(held_duck)
	get_parent().add_child(held_duck)

	# Calculate drop position in front of player
	var drop_offset: Vector3 = -transform.basis.z.normalized() * 1.5
	var drop_pos: Vector3 	 = global_transform.origin + drop_offset
	drop_pos.y = 0  # Clamp to ground height (adjust if needed)

	held_duck.global_position = drop_pos

	# Reactivate duck logic
	held_duck.set_physics_process(true)
	held_duck.set_process(true)

	# Update its spawn origin to current position
	if held_duck is Duck:
		held_duck.set_new_spawn_origin()
		duck_put_down_audio.play()

	# Clear held duck reference
	held_duck = null
	
func equip_brush(brush: Brush) -> void:
	held_brush = brush
	
	if brush.get_parent():
		brush.get_parent().remove_child(brush)
	
	# Attach the brush model to the hand or camera for visibility
	object_hold_point.add_child(brush)
	brush.transform = Transform3D.IDENTITY
	brush.scale = Vector3(0.7, 0.7, 0.7)
	brush.show()
	
func remove_brush():
	if held_brush:
		object_hold_point.remove_child(held_brush)
		held_brush = null
	
func _on_confirm_button_pressed() -> void:
	if held_duck and name_input.text.strip_edges() != "":
		held_duck.duck_name = name_input.text.strip_edges()
	naming_panel.visible = false
	in_naming_window = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	set_process_input(true)
	set_physics_process(true)
	
func _on_name_entered(text) -> void:
	if text.strip_edges() != "":
		_on_confirm_button_pressed()
		
func _on_has_food_taken() -> void:
	is_holding_food = true

func _on_duck_put_in_bath(duck: Duck):
	duck.bathe()
	duck_hold_point.remove_child(duck)
	held_duck = null

func _on_duck_retrieved_from_bath(duck: Duck):
	pick_up(duck)

func _on_player_entered_bath_area():
	in_bath_area = true

func _on_player_exited_bath_area():
	in_bath_area = false
