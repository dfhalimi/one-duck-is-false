class_name Zone3D
extends Area3D

signal player_entered_zone(context: int)
signal player_exited_zone(context: int)

enum Context { NONE, LAKE, PEN, HOUSE }
@export var context: Context = Context.NONE

func _on_body_entered(body):
	if body.name == "Player":
		player_entered_zone.emit(context)

func _on_body_exited(body):
	if body.name == "Player":
		player_exited_zone.emit(context)
