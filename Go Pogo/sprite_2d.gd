extends Sprite2D

func _process(_delta):
	var parent = get_parent()
	if parent.is_on_floor():
		var squash = (parent.current_x / parent.max_compression_x) * 0.15
		scale = Vector2(0.25 + squash, 0.25 - squash)
	else:
		# Stretch based on velocity
		var stretch = clamp(abs(parent.velocity.y) / 1000, 0, 0.1)
		scale = Vector2(0.25 - stretch, 0.25 + stretch)
		
	if parent.current_x >= parent.max_compression_x and not parent.is_buckling:
			# Make the sprite "shiver" or flash white to show it's fully charged
			modulate = Color(2, 2, 2) # Overbright/Glow effect
	else:
		modulate = Color(1, 1, 1) # Normal
