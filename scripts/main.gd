class_name Main
extends Node3D

@onready var pen_zone: Zone3D = $PenZone
@onready var house_zone: Zone3D = $HouseZone
@onready var next_day_popup: Panel = $UI/Control/NextDayPopup
@onready var objective_label: Label = $UI/Control/ObjectiveLabel
@onready var mailbox: Mailbox = $Mailbox
@onready var hint_popup: Panel = $UI/Control/HintPopup
@onready var hint_label: Label = $UI/Control/HintPopup/HintLabel

func _ready() -> void:
	game_manager.init(pen_zone, house_zone, next_day_popup)
	objective_manager.init(objective_label, mailbox, hint_popup, hint_label)
