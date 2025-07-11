class_name DuckBrain
extends Node

enum Trait {
	NOT_HUNGRY,
	DISLIKES_PETTING,
	STARES_AT_PLAYER
}

@export var duck_name: String = ""
@export var is_false_duck: bool = false

var is_dead: bool = false
var pet_counter: int = 0
var tickle_counter: int = 0
var traits: Array[Trait] = []

func _ready() -> void:
	assign_random_traits()

func assign_random_traits():
	var all_traits = [Trait.NOT_HUNGRY, Trait.DISLIKES_PETTING, Trait.STARES_AT_PLAYER]
	var max_traits = 1
	
	while traits.size() < max_traits:
		var new_trait = all_traits[randi() % all_traits.size()]
		if new_trait not in traits:
			traits.append(new_trait)
