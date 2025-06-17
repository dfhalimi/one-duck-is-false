extends CharacterBody3D

@export var mouse_sensitivity := 0.002
@export var move_speed := 5.0
@export var jump_velocity := 4.0

@onready var camera: Camera3D = $Camera3D
@onready var ray: RayCast3D = $Camera3D/RayCast3D
@onready var interact_prompt_label: Label = get_tree().get_root().get_node("Main/UI/Control/InteractPrompt")
@onready var duck_hold_point: Node3D = $Camera3D/DuckHoldPoint

@onready var naming_panel: Panel = $"../UI/Control/NamingPanel"
@onready var name_input: LineEdit = $"../UI/Control/NamingPanel/NameInput"
@onready var confirm_button: Button = $"../UI/Control/NamingPanel/ConfirmButton"

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var y_velocity := 0.0
var pitch := 0.0
var last_hovered_duck: Node = null
var current_zone: String = ""
var held_duck: Node3D = null

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	for zone in get_tree().get_nodes_in_group("zones"):
		zone.player_entered_zone.connect(_on_player_entered_zone)
		zone.player_exited_zone.connect(_on_player_exited_zone)
	
	name_input.text_submitted.connect(_on_name_entered)
	
func _process(_delta):
	# Priority: if holding a duck, and in the pen → show drop prompt
	if held_duck:
		if current_zone == "pen":
			interact_prompt_label.text = "[E] Put " + held_duck.get_duck_name() + " down"
			interact_prompt_label.visible = true
		else:
			# You’re holding a duck but not in pen → no action
			interact_prompt_label.visible = false
		return

	# Not holding a duck → check if you're aiming at one
	if ray.is_colliding():
		var hit = ray.get_collider()

		if hit and hit.has_method("get_duck_name"):
			if current_zone == "lake":
				interact_prompt_label.text = "[E] Pick up " + hit.get_duck_name()
				interact_prompt_label.visible = true
				
			if current_zone == "pen":
				interact_prompt_label.text = "[E] Pet " + hit.get_duck_name()
				interact_prompt_label.visible = true
				
			# Handle highlighting
			if last_hovered_duck != hit:
				if last_hovered_duck and last_hovered_duck.has_method("highlight"):
					last_hovered_duck.highlight(false)
				last_hovered_duck = hit
				if hit.has_method("highlight"):
					hit.highlight(true)
			return

	# No valid duck target
	interact_prompt_label.visible = false

	if last_hovered_duck:
		if last_hovered_duck.has_method("highlight"):
			last_hovered_duck.highlight(false)
		last_hovered_duck = null

func _physics_process(delta):
	var direction = Vector3.ZERO

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
	
func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		pitch = clamp(pitch - event.relative.y * mouse_sensitivity, deg_to_rad(-90), deg_to_rad(90))
		camera.rotation.x = pitch

func _unhandled_input(event):
	if event.is_action_pressed("interact"):
		if held_duck and current_zone == "pen":
			drop_held_duck()
		elif ray.is_colliding():
			var hit = ray.get_collider()
			if hit and hit.has_method("get_duck_name"):
				if current_zone == "lake":
					if !held_duck:
						pick_up(hit)
				elif current_zone == "pen":
					if !held_duck:
						hit.pet()
				
func _on_player_entered_zone(context: int):
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

func _on_player_exited_zone(context: int):
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
				
func pick_up(duck: Node3D):
	if held_duck:
		print("Already holding " + duck.get_duck_name() + "... Is that not enough for you?")
		return

	# Remove from old parent and add to player node
	if duck.get_parent():
		duck.get_parent().remove_child(duck)

	duck_hold_point.add_child(duck)
	held_duck = duck

	# Reset transform locally relative to hold point
	duck.transform = Transform3D.IDENTITY
	duck.velocity = Vector3.ZERO
	duck.set_physics_process(false)
	duck.set_process(false)
	
	# Show naming panel
	naming_panel.visible = true
	name_input.text = ""
	name_input.grab_focus()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	set_process_input(false)
	set_physics_process(false)
	
func drop_held_duck():
	if not held_duck:
		return

	# Remove from hold point and reparent to world
	duck_hold_point.remove_child(held_duck)
	get_parent().add_child(held_duck)

	# Calculate drop position in front of player
	var drop_offset = -transform.basis.z.normalized() * 1.5
	var drop_pos = global_transform.origin + drop_offset
	drop_pos.y = 0.5  # Clamp to ground height (adjust if needed)

	held_duck.global_position = drop_pos

	# Reactivate duck logic
	held_duck.set_physics_process(true)
	held_duck.set_process(true)

	# Update its spawn origin to current position
	if held_duck.has_method("set_new_spawn_origin"):
		held_duck.set_new_spawn_origin()

	# Clear held duck reference
	held_duck = null
	
func _on_confirm_button_pressed():
	if held_duck and name_input.text.strip_edges() != "":
		held_duck.duck_name = name_input.text.strip_edges()
	naming_panel.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	set_process_input(true)
	set_physics_process(true)
	
func _on_name_entered(text):
	if text.strip_edges() != "":
		_on_confirm_button_pressed()
