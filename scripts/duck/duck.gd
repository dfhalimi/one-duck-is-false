class_name Duck
extends CharacterBody3D

@onready var brain: DuckBrain = $DuckBrain
@onready var interaction: DuckInteraction = $DuckInteraction
@onready var mover: DuckMovement = $DuckMovement
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var animator: AnimationPlayer = $DuckModelPlaceholder/AnimationPlayer

var duck_name: String:
	get: return brain.duck_name
	set(value): brain.duck_name = value
	
var is_false_duck: bool:
	get: return brain.is_false_duck
	set(value): brain.is_false_duck = value
	
func _ready() -> void:
	set_new_spawn_origin()

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

func pet(): interaction.pet()
func tickle(): interaction.tickle()
func feed(): interaction.feed()
func accuse(): interaction.accuse()

func set_new_spawn_origin() -> void:
	mover.set_new_spawn_origin()
