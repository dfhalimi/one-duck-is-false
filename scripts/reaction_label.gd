extends Label3D

@onready var player = get_node_or_null("/root/Main/Player")

func _process(_delta):
	if player:
		look_at(player.global_transform.origin, Vector3.UP)
		rotate_y(PI) # flips to label
