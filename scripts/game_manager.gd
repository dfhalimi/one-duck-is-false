class_name GameManager
extends Node

signal next_day_reached

var pen_zone: Zone3D
var house_zone: Zone3D
var day_popup: Panel

var ducks_in_pen: int = 0
var last_duck_count: int = -1
var current_day: int = 1

var false_duck_assigned: bool = false
var false_duck: Duck = null
	
func _process(_delta) -> void:
	var current_count: int = get_duck_count_in_pen()
	if current_count != last_duck_count:
		objective_manager.notify_event(Objective.Type.DUCKS_IN_PEN)
		ducks_in_pen = current_count
		last_duck_count = current_count
		
func init(pen: Zone3D, house: Zone3D, popup: Panel) -> void:
	pen_zone = pen
	house_zone = house
	day_popup = popup
	house_zone.player_entered_zone.connect(check_win_condition)
		
func assign_false_duck() -> void:
	if false_duck_assigned:
		return
		
	var ducks: Array[Duck] = get_ducks_in_pen()
	if ducks.size() == 0:
		print("⚠️ No ducks found in the pen!")
		return
	
	false_duck = ducks[randi() % ducks.size()]
	false_duck.is_false_duck = true
	false_duck_assigned = true
	
	if false_duck.brain.has_no_traits():
		false_duck.brain.assign_random_traits()
	
	print("Assigned false duck.")
		
func get_ducks_in_pen() -> Array[Duck]:
	var ducks: Array[Duck] = []
	for body in pen_zone.get_overlapping_bodies():
		if body is Duck:
			ducks.append(body)
	return ducks
	
func get_duck_count_in_pen() -> int:
	var count := 0
	for body in pen_zone.get_overlapping_bodies():
		if body is Duck:
			count += 1
	return count

func check_win_condition(_context: Zone3D.Context) -> void:
	print("Check win condition triggered")
	if objective_manager.has_all_objectives_completed():
		if current_day >= 3:
			print("End of prototype.")
			return
			
		show_next_day_popup()
		go_to_next_day()
		
func get_current_day() -> int:
	return current_day

func show_next_day_popup() -> void:
	day_popup.visible = true
	await get_tree().create_timer(2.5).timeout
	day_popup.visible = false
	
func go_to_next_day() -> void:
	current_day += 1
	var duck_hint = generate_clue_for_mailbox()
	next_day_reached.emit(duck_hint)
	print("🌒 Welcome to Day %d" % current_day)
	
func generate_clue_for_mailbox() -> String:
	if not false_duck:
		return ""

	for duck_trait in false_duck.brain.traits:
		match duck_trait:
			DuckBrain.Trait.NOT_HUNGRY:
				return "One of the ducks hasn’t touched its food..."
			DuckBrain.Trait.DISLIKES_PETTING:
				return "There’s one duck that seems to hate affection..."
			DuckBrain.Trait.DISLIKES_BRUSHING:
				return "Someone really doesn't seem to like that brush..."
			DuckBrain.Trait.DISLIKES_BATHING:
				return "Seems like one of the ducks doesn't particularly enjoy water..."
			DuckBrain.Trait.STARES_AT_PLAYER:
				return "Looks like you're being watched..."
	return ""
