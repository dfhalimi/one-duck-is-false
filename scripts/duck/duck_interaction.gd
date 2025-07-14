class_name DuckInteraction
extends Node

@export var brain: DuckBrain

func pet() -> void:
	var pet_counter: int = brain.pet_counter
	objective_manager.notify_event(Objective.Type.PET_DUCK, brain.duck_name)
	brain.pet_counter += 1
	var duck_name: String = brain.duck_name
	
	if brain.traits.has(brain.Trait.DISLIKES_PETTING):
		print(duck_name + " didn't really enjoy that...")
	else:
		if pet_counter < 3:
			print(duck_name + " flaps happily.")
		elif pet_counter < 5:
			print(duck_name + " flaps a little less enthusiastically...")
		elif pet_counter < 10:
			print(duck_name + " is thinking this is enough petting for now...")
		else:
			print("OH MY GOD WOULD YOU STOP PETTING " + duck_name + " ALREADY?!")
			
func tickle()-> void:
	var tickle_counter: int = brain.tickle_counter
	brain.tickle_counter += 1
	var duck_name: String = brain.duck_name
	
	if tickle_counter < 3:
		print(duck_name + " chuckles happily.")
	elif tickle_counter < 5:
		print(duck_name + " laughs heartily.")
	elif tickle_counter <10:
		print(duck_name + " is starting to panic a little.")
	else:
		print("STOP IT YOU MONSTER " + duck_name + " IS THIS CLOSE TO GETTING A HEART ATTACK!!!")

func feed() -> void:
	objective_manager.notify_event(Objective.Type.FEED_DUCK, brain.duck_name)
	
	if brain.traits.has(brain.Trait.NOT_HUNGRY):
		print(brain.duck_name + " doesn't seem too hungry...")
	else:
		print(brain.duck_name + " munches the food happily.")
		
func brush() -> void:
	objective_manager.notify_event(Objective.Type.BRUSH_DUCK, brain.duck_name)
	
	if brain.traits.has(brain.Trait.DISLIKES_BRUSHING):
		print(brain.duck_name + " is really not enjoying this...")
	else:
		print(brain.duck_name + " is enjoying the brushing.")
		
func bathe() -> void:
	objective_manager.notify_event(Objective.Type.BATHE_DUCK, brain.duck_name)
	
	if brain.traits.has(brain.Trait.DISLIKES_BATHING):
		print(brain.duck_name + " accepts their fate...")
	else:
		print(brain.duck_name + " is loving that bath!")

func accuse() -> void:
	pass
