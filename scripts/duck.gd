extends CharacterBody3D

@export var speed: float = 2.0
@export var wander_radius: float = 3.0
@export var time_between_moves: float = 2.0
@export var is_false_duck: bool = false
@export var duck_name: String

@export var normal_material: Material
@export var highlight_material: Material
@export var dead_material: Material

@onready var body_mesh: MeshInstance3D = $BodyMesh
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var objective_manager: Node = $"../../ObjectiveManager"

var spawn_origin := Vector3.ZERO
var target_pos := Vector3.ZERO
var move_timer := 0.0
var pet_counter := 0
var is_dead: bool = false

func _ready():
	spawn_origin = global_position
	pick_new_target()

func _physics_process(delta):
	move_timer -= delta
	var distance = global_position.distance_squared_to(target_pos)

	if distance < 0.1 or move_timer <= 0:
		pick_new_target()

	var move_dir = (target_pos - global_position).normalized()
	velocity.x = move_dir.x * speed
	velocity.z = move_dir.z * speed
	move_and_slide()

func pick_new_target():
	move_timer = time_between_moves

	var rand_offset = Vector3(
		randf_range(-wander_radius, wander_radius),
		0,
		randf_range(-wander_radius, wander_radius)
	)

	target_pos = spawn_origin + rand_offset

func set_new_spawn_origin():
	spawn_origin = global_position

func accuse():
	if is_false_duck:
		print("YOU FOUND THE FALSE DUCK!")
	else:
		print(duck_name + " was just a normal duck...")
		
func pet():
	objective_manager.notify_event(ObjectiveManager.ObjectiveType.PET_DUCK, duck_name)
	pet_counter = pet_counter + 1
	if pet_counter < 3:
		print(duck_name + " flaps happily.")
	elif pet_counter < 5:
		print(duck_name + " flaps a little less enthusiastically...")
	elif pet_counter < 10:
		print(duck_name + " is thinking this is enough petting for now...")
	elif pet_counter >= 10:
		print("OH MY GOD WOULD YOU STOP PETTING " + duck_name + " ALREADY?!")
		
func feed():
	objective_manager.notify_event(ObjectiveManager.ObjectiveType.FEED_DUCKS)
	print(duck_name + " munches the food happily.")

func get_duck_name() -> String:
	return duck_name

func highlight(enable: bool):
	if not is_dead and body_mesh:
		body_mesh.set_surface_override_material(0, highlight_material if enable else normal_material)
		
func die():
	is_dead = true
	set_physics_process(false)
	set_process(false)
	collision_shape_3d.disabled = true
	body_mesh.set_surface_override_material(0, dead_material)
