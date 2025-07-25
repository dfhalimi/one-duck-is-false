class_name Mailbox
extends StaticBody3D

@onready var interaction_area: Area3D = $InteractionArea
@onready var prompt: Label3D = $InteractionArea/PromptLabel
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var player_nearby: bool = false
var mail_read: bool = false
var duck_hint: String = ""
var is_open = false

signal mail_read_requested

func _ready() -> void:
	prompt.visible = false
	game_manager.next_day_reached.connect(_on_next_day_reached)

func _on_body_entered(body) -> void:
	if body.name == "Player" and not mail_read:
		player_nearby = true
		prompt.visible = true

func _on_body_exited(body) -> void:
	if body.name == "Player":
		player_nearby = false
		prompt.visible = false
		
		if is_open:
			is_open = false
			animation_player.play("close_door")
		
func _on_next_day_reached(hint: String) -> void:
	duck_hint = hint
	mail_read = false

func _process(_delta) -> void:
	if player_nearby and Input.is_action_just_pressed("interact") and not mail_read:
		print("Reading mail...")
		mail_read_requested.emit(duck_hint)
		mail_read = true
		prompt.visible = false
		is_open = true
		animation_player.play("open_door")
