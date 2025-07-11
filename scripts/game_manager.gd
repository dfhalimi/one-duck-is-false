class_name GameManager
extends Node

signal made_wrong_accusation
signal next_day_reached

var pen_zone: Zone3D
var house_zone: Zone3D
var day_popup: Panel

var ducks_in_pen : int = 0
var last_duck_count : int = -1
var current_day : int = 1
var max_attempts : int = 3
var attempts_left : int = 3
var has_accused : bool = false
var game_won : bool = false
var game_lost : bool = false

var false_duck_assigned : bool = false
var false_duck : Duck = null
	
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
	if game_lost:
		print("💀 You lost. The false duck was: %s" % false_duck.duck_name)
		return
	if objective_manager.has_all_objectives_completed():
		if not has_accused:
			print("All objectives completed. Please accuse a duck before ending the day.")
		elif has_accused and not game_won:
			print("You failed to identify the false duck.")
			show_next_day_popup()
			go_to_next_day()
		elif has_accused and game_won:
			print("YOU WIN! The false duck has been found.")
			# No next day. Game ends.
			
func handle_accusation_result(correct: bool) -> void:
	if game_won or game_lost:
		return
		
	has_accused = true
	
	if correct:
		game_won = true
		print("✅ Correct! You win!")
	else:
		attempts_left -= 1
		print("❌ Wrong duck. Attempts left: %d" % attempts_left)
		made_wrong_accusation.emit()
		
		if attempts_left <= 0:
			game_lost = true
			print("💀 Game over. The false duck wins. It was %s" % false_duck.duck_name + " all along...")
		
func get_current_day() -> int:
	return current_day
	
func can_accuse() -> bool:
	if objective_manager.has_all_objectives_completed() and not has_accused:
		if not false_duck_assigned:
			assign_false_duck()
		return true
		
	return false

func show_next_day_popup() -> void:
	day_popup.visible = true
	await get_tree().create_timer(2.5).timeout
	day_popup.visible = false
	
func go_to_next_day() -> void:
	current_day += 1
	has_accused = false
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
			DuckBrain.Trait.STARES_AT_PLAYER:
				return "Looks like you're being watched..."
	return ""
