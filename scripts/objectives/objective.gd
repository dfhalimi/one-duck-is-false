class_name Objective
extends RefCounted  # lightweight class

enum Type {
	DUCKS_IN_PEN,
	PET_DUCK,
	FEED_DUCKS,
	BRUSH_DUCKS
}

var type: Type
var amount: int = 1
var target: String = ""
var completed: bool = false
var count: int = 0

func _init(obj_type: Type, amt: int = 1, tgt: String = ""):
	type = obj_type
	amount = amt
	target = tgt
