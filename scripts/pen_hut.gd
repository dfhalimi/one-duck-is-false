class_name PenHut
extends StaticBody3D

@onready var interaction_area: Area3D = $InteractionArea
@onready var prompt: Label3D = $InteractionArea/PromptLabel
@onready var hut_area: Area3D = $HutArea
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var player_nearby: bool = false
var is_open: bool = false

func _ready() -> void:
	prompt.visible = false

func _on_interaction_area_body_entered(body: Node3D) -> void:
	if body.name == "Player" and not is_open:
		player_nearby = true
		prompt.visible = true

func _on_interaction_area_body_exited(body: Node3D) -> void:
	if body.name == "Player":
		player_nearby = false
		prompt.visible = false
			
func _on_hut_area_body_exited(body: Node3D) -> void:
	if body.name == "Player":
		if is_open:
			is_open = false
			animation_player.play("close_door")

func _process(_delta) -> void:
	if player_nearby and Input.is_action_just_pressed("interact") and not is_open:
		prompt.visible = false
		is_open = true
		animation_player.play("open_door")
