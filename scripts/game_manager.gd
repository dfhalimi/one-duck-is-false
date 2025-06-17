extends Node

@export var ducks_required: int = 5

@onready var objective_label: Label = get_tree().get_root().get_node("Main/UI/Control/ObjectiveLabel")
@onready var pen_zone: Zone3D = $"../PenZone"
@onready var objective_popup: Panel = $"../UI/Control/ObjectivePopup"
@onready var continue_button: Button = $"../UI/Control/ObjectivePopup/ContinueButton"
@onready var player: CharacterBody3D = $"../Player"

var ducks_in_pen := 0
var last_duck_count := -1
var objective_completed := false

func _ready():
	update_duck_label()
	
func _process(_delta) -> void:
	if not objective_completed:
		var current_count = get_duck_count_in_pen()
		if current_count != last_duck_count:
			ducks_in_pen = current_count
			last_duck_count = current_count
			update_duck_label()
			check_win_condition()
	
func get_duck_count_in_pen() -> int:
	var count := 0
	for body in pen_zone.get_overlapping_bodies():
		if body.is_in_group("ducks"):
			count += 1
	return count

func update_duck_label():
	objective_label.text = "Ducks collected: %d / %d" % [ducks_in_pen, ducks_required]

func check_win_condition():
	if not objective_completed and ducks_in_pen >= ducks_required:
		objective_completed = true
		show_objective_popup()
		
func show_objective_popup():
	objective_popup.visible = true
	continue_button.grab_focus()
	player.set_process_input(false)
	player.set_physics_process(false)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
func _on_continue_button_pressed():
	objective_popup.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	player.set_process_input(true)
	player.set_physics_process(true)
	
	# Optionally: Advance to next day, reset ducks, etc.
