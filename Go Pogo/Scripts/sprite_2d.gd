extends Sprite2D

func _process(_delta):
	var parent = get_parent()
	
	# 1. SQUASH & STRETCH
	if parent.is_on_floor():
		var squash = (parent.current_x / parent.max_compression_x) * 0.15
		scale = Vector2(0.25 + squash, 0.25 - squash)
	else:
		var stretch = clamp(abs(parent.velocity.y) / 1000, 0, 0.1)
		scale = Vector2(0.25 - stretch, 0.25 + stretch)
		
	# 2. FULL CHARGE GLOW
	if parent.current_x >= parent.max_compression_x and not parent.is_buckling:
		modulate = Color(2, 2, 2) # Overbright glow
	else:
		# We don't reset to WHITE here because the bail flash might be running
		if modulate.a == 1.0: # Only reset if we aren't currently flashing
			modulate = Color(1, 1, 1)

## Called by LandingManager on a bad landing
func play_bail_flash():
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 0, 0, 0.5), 0.1) # Red Tint
	tween.tween_property(self, "modulate", Color(1, 1, 1, 1.0), 0.1)
	tween.set_loops(3)
