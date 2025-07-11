class_name BrushHolder
extends StaticBody3D

@onready var interaction_area: Area3D = $InteractionArea
@onready var prompt: Label3D = $InteractionArea/PromptLabel
@onready var player: Player = $"../Player"

var player_nearby : bool = false
var brush_taken : bool = false

signal has_taken_brush
signal has_returned_brush

func _ready() -> void:
	prompt.visible = false

func _on_body_entered(body) -> void:
	if body is Player:
		print("Player entered brush holder area")
		player_nearby = true
		
		if not player.is_holding_food:
			prompt.visible = true
		
func _on_body_exited(body) -> void:
	if body is Player:
		print("Player exited brush holder area")
		player_nearby = false
		prompt.visible = false
		
func _process(_delta) -> void:
	if player_nearby and Input.is_action_just_pressed("interact") and player.held_duck == null and not player.is_holding_food:
		if brush_taken:
			print("Putting brush back...")
			brush_taken = false
			prompt.text = "[E] Pick up brush"
			has_returned_brush.emit()
			return
			
		print("Taking brush...")
		brush_taken = true
		prompt.text = "[E] Put brush back"
		has_taken_brush.emit()
