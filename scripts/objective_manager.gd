class_name ObjectiveManager
extends Node

var objective_label: Label
var mailbox: Mailbox
var hint_popup: Panel
var hint_label: Label

var objective_list : Array[Objective] = []
var all_objectives_completed : bool = false
var has_started_objectives_for_the_day : bool = false
var accuse_objective_text_displayed : bool = false
	
func init(obj_label: Label, mail: Mailbox, h_popup: Panel, h_label: Label) -> void:
	objective_label = obj_label
	mailbox = mail
	mailbox.mail_read_requested.connect(display_mail)
	hint_popup = h_popup
	hint_label = h_label
	game_manager.made_wrong_accusation.connect(handle_wrong_accusation)
	game_manager.next_day_reached.connect(reset)
	reset_objective_ui()

func display_mail(hint: String) -> void:
	if hint:
		show_hint(hint)
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
				ducks.shuffle()  # So we get random ones

				for i in range(min(2, ducks.size())):
					var duck: Duck = ducks[i]
					objectives.append(Objective.new(Objective.Type.PET_DUCK, 1, duck.duck_name))
					
				objectives.append(Objective.new(Objective.Type.FEED_DUCKS, 2))
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
			Objective.Type.FEED_DUCKS:
				var count = obj.count
				text += "%s Feed %d ducks (%d/%d)\n" % [status, obj.amount, count, obj.amount]
	objective_label.text = text
	
func handle_wrong_accusation() -> void:
	objective_label.text = "Return back to the house"

func reset(_hint) -> void:
	reset_objective_ui()
	all_objectives_completed = false
	has_started_objectives_for_the_day = false
	accuse_objective_text_displayed = false

func reset_objective_ui() -> void:
	objective_label.text = "Check mailbox"
	
func notify_event(event_type: int, data = null) -> void:
	if has_started_objectives_for_the_day:
		for obj in objective_list:
			if obj.completed:
				continue
			match obj.type:
				Objective.Type.DUCKS_IN_PEN:
					var count: int = game_manager.get_duck_count_in_pen()
					if count >= obj.amount:
						obj.completed = true
				Objective.Type.PET_DUCK:
					if event_type == Objective.Type.PET_DUCK and data == obj.target:
						obj.completed = true
				Objective.Type.FEED_DUCKS:
					if event_type == Objective.Type.FEED_DUCKS:
						obj.count += 1
						if obj.count >= obj.amount:
							obj.completed = true
							
		if not has_all_objectives_completed() and not accuse_objective_text_displayed:
			update_objective_ui()
		check_all_completed()

func check_all_completed() -> void:
	if objective_list.all(func(o): return o.completed):
		all_objectives_completed = true
		if not accuse_objective_text_displayed:
			objective_label.text = "Find and accuse the false duck"
			accuse_objective_text_displayed = true
		
func get_objective_list() -> Array[Objective]:
	return objective_list

func has_all_objectives_completed() -> bool:
	return all_objectives_completed
