class_name Zone3D
extends Area3D

enum Context { NONE, LAKE, PEN, HOUSE }

signal player_entered_zone(context: Context)
signal player_exited_zone(context: Context)

@export var context: Context = Context.NONE

func _on_body_entered(body) -> void:
	if body.name == "Player":
		player_entered_zone.emit(context)

func _on_body_exited(body) -> void:
	if body.name == "Player":
		player_exited_zone.emit(context)
