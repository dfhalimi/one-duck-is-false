class_name Brush
extends Area3D

func put_back(target_transform: Transform3D) -> void:
	var randomized_transform = target_transform

	var new_rotation = target_transform.basis.get_euler()
	new_rotation.y = randf_range(0.0, TAU)  # Apply the randomness to the basis

	randomized_transform.basis = Basis.from_euler(new_rotation)
	global_transform = randomized_transform
