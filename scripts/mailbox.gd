extends StaticBody3D

@onready var interaction_area: Area3D = $InteractionArea
@onready var prompt: Label3D = $InteractionArea/PromptLabel
@onready var game_manager: Node = $"../GameManager"

var player_nearby := false
var mail_read := false
signal mail_read_requested

func _ready():
	prompt.visible = false
	game_manager.next_day_reached.connect(_on_next_day_reached)

func _on_body_entered(body):
	if body.name == "Player" and not mail_read:
		player_nearby = true
		prompt.visible = true

func _on_body_exited(body):
	if body.name == "Player":
		player_nearby = false
		prompt.visible = false
		
func _on_next_day_reached():
	mail_read = false

func _process(_delta):
	if player_nearby and Input.is_action_just_pressed("interact") and not mail_read:
		print("Reading mail...")
		mail_read_requested.emit()
		mail_read = true
		prompt.visible = false
