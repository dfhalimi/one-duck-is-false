class_name DuckBrain
extends Node

enum Trait {
	NOT_HUNGRY,
	DISLIKES_PETTING,
	DISLIKES_BRUSHING,
	DISLIKES_BATHING,
	STARES_AT_PLAYER
}

@export var duck_name: String = ""
@export var is_false_duck: bool = false
@export var traits: Array[Trait] = []

var is_dead: bool = false
var pet_counter: int = 0
var tickle_counter: int = 0

func _ready() -> void:
	assign_random_traits()

func assign_random_traits() -> void:
	var all_traits = Trait.values()
	var max_traits = 1
	
	while traits.size() < max_traits:
		var new_trait = all_traits[randi() % all_traits.size()]
		if new_trait not in traits:
			traits.append(new_trait)
			
func has_no_traits() -> bool:
	return traits.is_empty()
