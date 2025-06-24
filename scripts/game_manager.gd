extends Node

@onready var pen_zone: Zone3D = $"../PenZone"
@onready var house_zone: Zone3D = $"../HouseZone"
@onready var day_popup: Panel = $"../UI/Control/NextDayPopup"
@onready var player: CharacterBody3D = $"../Player"
@onready var objective_manager: Node = $"../ObjectiveManager"

signal made_wrong_accusation
signal next_day_reached

var ducks_in_pen := 0
var last_duck_count := -1
var current_day := 1
var max_attempts := 3
var attempts_left := 3
var has_accused := false
var game_won := false
var game_lost := false

var false_duck_assigned := false
var false_duck : Node = null

func _ready() -> void:
	house_zone.player_entered_zone.connect(check_win_condition)
	
func _process(_delta) -> void:
	var current_count = get_duck_count_in_pen()
	if current_count != last_duck_count:
		objective_manager.notify_event(ObjectiveManager.ObjectiveType.DUCKS_IN_PEN)
		ducks_in_pen = current_count
		last_duck_count = current_count
		
func assign_false_duck():
	if false_duck_assigned:
		return
		
	var ducks = get_ducks_in_pen()
	if ducks.size() == 0:
		print("⚠️ No ducks found in the pen!")
		return
	
	false_duck = ducks[randi() % ducks.size()]
	false_duck.is_false_duck = true
	false_duck_assigned = true
		
func get_ducks_in_pen():
	var ducks = []
	for body in pen_zone.get_overlapping_bodies():
		if body.is_in_group("ducks"):
			ducks.append(body)
	return ducks
	
func get_duck_count_in_pen() -> int:
	var count := 0
	for body in pen_zone.get_overlapping_bodies():
		if body.is_in_group("ducks"):
			count += 1
	return count

func check_win_condition(_context: int):
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
			
func handle_accusation_result(correct: bool):
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
		
func get_current_day():
	return current_day
	
func can_accuse():
	if objective_manager.has_all_objectives_completed() and not has_accused:
		if not false_duck_assigned:
			assign_false_duck()
		return true
		
	return false

func show_next_day_popup():
	day_popup.visible = true
	await get_tree().create_timer(2.5).timeout
	day_popup.visible = false
	
func go_to_next_day():
	current_day += 1
	has_accused = false
	next_day_reached.emit()
	print("🌒 Welcome to Day %d" % current_day)
