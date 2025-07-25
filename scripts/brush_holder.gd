class_name BrushHolder
extends StaticBody3D

@onready var brush: Brush = $Brush
@onready var interaction_area: Area3D = $InteractionArea
@onready var prompt: Label3D = $InteractionArea/PromptLabel
@onready var player: Player = $"../Player"
@onready var brush_pickup_audio: AudioStreamPlayer3D = $BrushPickupAudio
@onready var brush_put_down_audio: AudioStreamPlayer3D = $BrushPutDownAudio

var player_nearby: bool = false
var original_brush_transform: Transform3D

func _ready() -> void:
	prompt.visible = false
	original_brush_transform = brush.global_transform

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
		if player.held_brush:
			print("Putting brush back...")
			player.remove_brush()
			self.add_child(brush)
			brush.put_back(original_brush_transform)
			prompt.text = "[E] Pick up brush"
			brush_put_down_audio.pitch_scale = randf_range(0.9, 1.1)
			brush_put_down_audio.play()
			return
			
		print("Taking brush...")
		player.equip_brush(brush)
		prompt.text = "[E] Put brush back"
		brush_pickup_audio.pitch_scale = randf_range(0.9, 1.1)
		brush_pickup_audio.play()
