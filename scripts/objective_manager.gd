class_name ObjectiveManager
extends Node

var objective_label: Label
var mailbox: Mailbox
var hint_popup: Panel
var hint_label: Label

var objective_list : Array[Objective] = []
var all_objectives_completed : bool = false
var has_started_objectives_for_the_day : bool = false
	
func init(obj_label: Label, mail: Mailbox, h_popup: Panel, h_label: Label) -> void:
	objective_label = obj_label
	mailbox = mail
	mailbox.mail_read_requested.connect(display_mail)
	hint_popup = h_popup
	hint_label = h_label
	game_manager.next_day_reached.connect(reset)
	reset_objective_ui()

func display_mail(hint: String) -> void:
	if hint:
		print("Hint is " + hint)
		show_hint(hint)
	else:
		print("No hint found...")
	objective_list = generate_objectives_for_day(game_manager.get_current_day())
	update_objective_ui()
	
func show_hint(hint: String) -> void:
	hint_label.text = hint
	hint_popup.visible = true
	await get_tree().create_timer(2.5).timeout
	hint_popup.visible = false

func generate_objectives_for_day(day: int) -> Array[Objective]:
	var objectives: Array[Objective] = []
	has_started_objectives_for_the_day = true
	match day:
		1:
			objectives.append(Objective.new(Objective.Type.DUCKS_IN_PEN, 5))
		_:
			var ducks: Array[Duck] = game_manager.get_ducks_in_pen()
			if ducks.size() == 0:
				objectives.append(Objective.new(Objective.Type.DUCKS_IN_PEN, 2))
			else:
				for type in Objective.Type.values():
					if type != Objective.Type.DUCKS_IN_PEN:
						objectives = generate_objectives_for_type(ducks, objectives, type)
						
	return objectives
	
func generate_objectives_for_type(ducks: Array[Duck], objectives: Array[Objective], type: Objective.Type) -> Array[Objective]:
	ducks.shuffle()
	
	for i in range(min(2, ducks.size())):
		var duck: Duck = ducks[i]
		objectives.append(Objective.new(type, 1, duck.duck_name))
		
	return objectives

func update_objective_ui() -> void:
	var text := "Objectives:\n"
	for obj in objective_list:
		var status: String = "[✓]" if obj.completed else "[ ]"
		match obj.type:
			Objective.Type.DUCKS_IN_PEN:
				var current: int = game_manager.get_duck_count_in_pen()
				text += "%s Have %d ducks in the pen (%d/%d)\n" % [status, obj.amount, current, obj.amount]
			Objective.Type.PET_DUCK:
				text += "%s Pet %s\n" % [status, obj.target]
			Objective.Type.FEED_DUCK:
				text += "%s Feed %s\n" % [status, obj.target]
			Objective.Type.BRUSH_DUCK:
				text += "%s Brush %s\n" % [status, obj.target]
			Objective.Type.BATHE_DUCK:
				text += "%s Bathe %s\n" % [status, obj.target]
	objective_label.text = text

func reset(_hint) -> void:
	reset_objective_ui()
	all_objectives_completed = false
	has_started_objectives_for_the_day = false

func reset_objective_ui() -> void:
	objective_label.text = "Check mailbox"
	
func notify_event(event_type: int, data = null) -> void:
	if has_started_objectives_for_the_day:
		for obj in objective_list:
			if obj.completed:
				continue
			if obj.type != event_type:
				continue
				
			match event_type:
				Objective.Type.DUCKS_IN_PEN:
					var count: int = game_manager.get_duck_count_in_pen()
					if count >= obj.amount:
						obj.completed = true
						# This is a little hack for now and should be removed later for cleaner code
						game_manager.assign_false_duck()
				_:
					if obj.type == event_type and data == obj.target:
						obj.completed = true
							
		if not has_all_objectives_completed():
			update_objective_ui()
		check_all_completed()

func check_all_completed() -> void:
	if objective_list.all(func(o): return o.completed):
		all_objectives_completed = true
		objective_label.text = "Return back to the house"
		
func get_objective_list() -> Array[Objective]:
	return objective_list

func has_all_objectives_completed() -> bool:
	return all_objectives_completed
