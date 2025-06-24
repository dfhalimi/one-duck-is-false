class_name ObjectiveManager
extends Node

enum ObjectiveType { DUCKS_IN_PEN, PET_DUCK, FEED_DUCKS }

@onready var game_manager: Node = $"../GameManager"
@onready var objective_label: Label = $"../UI/Control/ObjectiveLabel"
@onready var mailbox: StaticBody3D = $"../Mailbox"

var objective_list := []
var all_objectives_completed : bool = false
var has_started_objectives_for_the_day : bool = false
var accuse_objective_text_displayed : bool = false

func _ready():
	mailbox.mail_read_requested.connect(display_mail)
	game_manager.made_wrong_accusation.connect(handle_wrong_accusation)
	game_manager.next_day_reached.connect(reset)
	reset_objective_ui()

func display_mail():
	objective_list = generate_objectives_for_day(game_manager.get_current_day())
	update_objective_ui()

func generate_objectives_for_day(day: int) -> Array:
	var objectives = []
	has_started_objectives_for_the_day = true
	match day:
		1:
			objectives.append({"objective_type": ObjectiveType.DUCKS_IN_PEN, "amount": 5, "completed": false})
		_:
			var ducks = game_manager.get_ducks_in_pen()
			if ducks.size() == 0:
				objectives.append({
					"objective_type": ObjectiveType.DUCKS_IN_PEN,
					"amount": 2,
					"completed": false
				})
			else:
				ducks.shuffle()  # So we get random ones

				for i in range(min(2, ducks.size())):
					var duck = ducks[i]
					objectives.append({
						"objective_type": ObjectiveType.PET_DUCK,
						"target": duck.duck_name,
						"completed": false
					})
					
				objectives.append({"objective_type": ObjectiveType.FEED_DUCKS, "amount": 2, "completed": false})
	return objectives

func update_objective_ui():
	var text := "Objectives:\n"
	for obj in objective_list:
		var status = "[✓]" if obj.completed else "[ ]"
		match obj.objective_type:
			ObjectiveType.DUCKS_IN_PEN:
				var current = game_manager.get_duck_count_in_pen()
				text += "%s Have %d ducks in the pen (%d/%d)\n" % [status, obj.amount, current, obj.amount]
			ObjectiveType.PET_DUCK:
				text += "%s Pet %s\n" % [status, obj.target]
			ObjectiveType.FEED_DUCKS:
				var count = obj.get("count", 0)
				text += "%s Feed %d ducks (%d/%d)\n" % [status, obj.amount, count, obj.amount]
	objective_label.text = text
	
func handle_wrong_accusation():
	objective_label.text = "Return back to the house"

func reset():
	reset_objective_ui()
	all_objectives_completed = false
	has_started_objectives_for_the_day = false
	accuse_objective_text_displayed = false

func reset_objective_ui():
	objective_label.text = "Check mailbox"
	
func notify_event(event_type: ObjectiveType, data = null):
	if has_started_objectives_for_the_day:
		for obj in objective_list:
			if obj.completed:
				continue
			match obj.objective_type:
				ObjectiveType.DUCKS_IN_PEN:
					var count = game_manager.get_duck_count_in_pen()
					if count >= obj.amount:
						obj.completed = true
				ObjectiveType.PET_DUCK:
					if event_type == ObjectiveType.PET_DUCK and data == obj.target:
						obj.completed = true
				ObjectiveType.FEED_DUCKS:
					if event_type == ObjectiveType.FEED_DUCKS:
						if "count" in obj:
							obj.count += 1
						else:
							obj.count = 1
						if obj.count >= obj.amount:
							obj.completed = true
		if not has_all_objectives_completed() and not accuse_objective_text_displayed:
			update_objective_ui()
		check_all_completed()

func check_all_completed():
	if objective_list.all(func(o): return o.completed):
		all_objectives_completed = true
		if not accuse_objective_text_displayed:
			objective_label.text = "Find and accuse the false duck"
			accuse_objective_text_displayed = true
		
func get_objective_list():
	return objective_list

func has_all_objectives_completed():
	return all_objectives_completed
