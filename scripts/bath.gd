class_name Bath
extends StaticBody3D

@onready var interaction_area: Area3D = $InteractionArea
@onready var prompt: Label3D = $InteractionArea/PromptLabel
@onready var player: Player = $"../Player"
@onready var bathing_point: Node3D = $BathingPoint

var player_nearby: bool = false
var duck_currently_in_bath: Duck = null

signal has_put_duck_into_bath
signal has_retrieved_duck_from_bath
signal player_entered_bath_area
signal player_exited_bath_area

func _ready() -> void:
	prompt.visible = false
	
func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		print("Player entered bathing area")
		player_nearby = true
		player_entered_bath_area.emit()
		
		if player.is_holding_food:
			print("Player is holding food")
		
		if not player.held_duck:
			if player.is_holding_food or player.is_holding_brush:
				prompt.text = "Cannot bathe while holding food or brush."
			elif duck_currently_in_bath:
				prompt.text = "[E] Pick up " + duck_currently_in_bath.brain.duck_name
			else:
				prompt.text = "Pick up a duck to bathe it."
			prompt.visible = true
		else:
			if duck_currently_in_bath:
				prompt.text = "Retrieve " + duck_currently_in_bath.brain.duck_name + " from the bath first."
			else:
				prompt.text = "[E] Bathe " + player.held_duck.brain.duck_name
			prompt.visible = true

func _on_body_exited(body: Node3D) -> void:
	if body is Player:
		print("Player exited bathing area")
		player_nearby = false
		prompt.visible = false
		player_exited_bath_area.emit()

func _process(_delta) -> void:
	if player_nearby and Input.is_action_just_pressed("interact"):
		if not player.held_duck:
			if duck_currently_in_bath and not player.is_holding_food and not player.is_holding_brush:
				var duck_name = duck_currently_in_bath.brain.duck_name
				print("Picking up " + duck_name + " from their bath...")
				var retrieved_duck = duck_currently_in_bath
				duck_currently_in_bath = null
				prompt.text = "[E] Bathe " + retrieved_duck.brain.duck_name
				has_retrieved_duck_from_bath.emit(retrieved_duck)
		elif not duck_currently_in_bath:
			var duck_name = player.held_duck.brain.duck_name
			print("Giving " + duck_name + " a nice little bath...")
			duck_currently_in_bath = player.held_duck
			prompt.text = "[E] Pick up " + duck_name
			has_put_duck_into_bath.emit(duck_currently_in_bath)
			bathing_point.add_child(duck_currently_in_bath)
