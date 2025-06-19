extends StaticBody3D

@onready var interaction_area: Area3D = $InteractionArea
@onready var prompt: Label3D = $InteractionArea/PromptLabel
@onready var player: CharacterBody3D = $"../Player"

var player_nearby := false
var food_taken := false

signal has_food_taken

func _ready():
	prompt.visible = false
	player.has_fed_duck.connect(_on_has_fed_duck)

func _on_body_entered(body):
	if body.name == "Player" and not food_taken:
		print("Player entered food tray area")
		player_nearby = true
		prompt.visible = true

func _on_body_exited(body):
	if body.name == "Player":
		player_nearby = false
		prompt.visible = false
		
func _on_has_fed_duck():
	print("Duck has been fed")
	prompt.visible = true
	food_taken = false

func _process(_delta):
	if player_nearby and Input.is_action_just_pressed("interact") and not food_taken:
		print("Taking food...")
		food_taken = true
		prompt.visible = false
		has_food_taken.emit()
