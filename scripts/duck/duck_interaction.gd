class_name DuckInteraction
extends Node

@export var brain: DuckBrain

@onready var reaction_label: Label3D = $"../ReactionLabel"

func pet() -> void:
	var pet_counter: int = brain.pet_counter
	objective_manager.notify_event(Objective.Type.PET_DUCK, brain.duck_name)
	brain.pet_counter += 1
	var duck_name: String = brain.duck_name
	
	if brain.traits.has(brain.Trait.DISLIKES_PETTING):
		show_reaction(duck_name + " didn't really enjoy that...")
	else:
		if pet_counter < 3:
			show_reaction(duck_name + " flaps happily.")
		elif pet_counter < 5:
			show_reaction(duck_name + " flaps a little less enthusiastically...")
		elif pet_counter < 10:
			show_reaction(duck_name + " is thinking this is enough petting for now...")
		else:
			show_reaction("OH MY GOD WOULD YOU STOP PETTING " + duck_name + " ALREADY?!")
			
func tickle()-> void:
	var tickle_counter: int = brain.tickle_counter
	brain.tickle_counter += 1
	var duck_name: String = brain.duck_name
	
	if tickle_counter < 3:
		show_reaction(duck_name + " chuckles happily.")
	elif tickle_counter < 5:
		show_reaction(duck_name + " laughs heartily.")
	elif tickle_counter <10:
		show_reaction(duck_name + " is starting to panic a little.")
	else:
		show_reaction("STOP IT YOU MONSTER " + duck_name + " IS THIS CLOSE TO GETTING A HEART ATTACK!!!")

func feed() -> void:
	objective_manager.notify_event(Objective.Type.FEED_DUCK, brain.duck_name)
	
	if brain.traits.has(brain.Trait.NOT_HUNGRY):
		show_reaction(brain.duck_name + " doesn't seem too hungry...")
	else:
		show_reaction(brain.duck_name + " munches the food happily.")
		
func brush() -> void:
	objective_manager.notify_event(Objective.Type.BRUSH_DUCK, brain.duck_name)
	
	if brain.traits.has(brain.Trait.DISLIKES_BRUSHING):
		show_reaction(brain.duck_name + " is really not enjoying this...")
	else:
		show_reaction(brain.duck_name + " is enjoying the brushing.")
		
func bathe() -> void:
	objective_manager.notify_event(Objective.Type.BATHE_DUCK, brain.duck_name)
	
	if brain.traits.has(brain.Trait.DISLIKES_BATHING):
		show_reaction(brain.duck_name + " accepts their fate...")
	else:
		show_reaction(brain.duck_name + " is loving that bath!")

func accuse() -> void:
	pass
	
func show_reaction(text: String, duration := 2.0) -> void:
	reaction_label.text = text
	reaction_label.visible = true

	await get_tree().create_timer(duration).timeout
	reaction_label.visible = false
