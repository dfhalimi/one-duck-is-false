extends Node

@onready var pen_zone: Zone3D = $"../PenZone"
@onready var house_zone: Zone3D = $"../HouseZone"
@onready var day_popup: Panel = $"../UI/Control/NextDayPopup"
@onready var player: CharacterBody3D = $"../Player"
@onready var objective_manager: Node = $"../ObjectiveManager"

signal next_day_reached

var ducks_in_pen := 0
var last_duck_count := -1
var current_day := 1

func _ready() -> void:
	house_zone.player_entered_zone.connect(check_win_condition)
	
func _process(_delta) -> void:
	var current_count = get_duck_count_in_pen()
	if current_count != last_duck_count:
		objective_manager.notify_event(ObjectiveManager.ObjectiveType.DUCKS_IN_PEN)
		ducks_in_pen = current_count
		last_duck_count = current_count
		
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
	if objective_manager.has_all_objectives_completed():
		print("All objectives completed!")
		show_next_day_popup()
		go_to_next_day()
		
func get_current_day():
	return current_day

func show_next_day_popup():
	day_popup.visible = true
	await get_tree().create_timer(2.5).timeout
	day_popup.visible = false
	
func go_to_next_day():
	current_day += 1
	next_day_reached.emit()
	print("🌒 Welcome to Day %d" % current_day)
