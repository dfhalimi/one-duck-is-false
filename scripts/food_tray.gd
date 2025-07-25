class_name FoodTray
extends StaticBody3D

@onready var interaction_area: Area3D = $InteractionArea
@onready var prompt: Label3D = $InteractionArea/PromptLabel
@onready var player: Player = $"../Player"
@onready var audio_stream_player: AudioStreamPlayer3D = $AudioStreamPlayer3D

var player_nearby : bool = false
var food_taken : bool = false

signal has_food_taken

func _ready() -> void:
	prompt.visible = false
	player.has_fed_duck.connect(_on_has_fed_duck)

func _on_body_entered(body) -> void:
	if body is Player and not food_taken:
		print("Player entered food tray area")
		player_nearby = true
		
		if not player.held_brush:
			prompt.visible = true

func _on_body_exited(body) -> void:
	if body is Player:
		print("Player exited food tray area")
		player_nearby = false
		prompt.visible = false
		
func _on_has_fed_duck() -> void:
	print("Duck has been fed")
	food_taken = false

func _process(_delta) -> void:
	if player_nearby and Input.is_action_just_pressed("interact") and not food_taken and player.held_duck == null and not player.held_brush:
		print("Taking food...")
		food_taken = true
		prompt.visible = false
		has_food_taken.emit()
		audio_stream_player.pitch_scale = randf_range(0.9, 1.1)
		audio_stream_player.play()
