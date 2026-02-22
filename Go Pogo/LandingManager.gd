extends Node2D

signal landing_processed(msg, is_bad)

@onready var player = get_parent()
@onready var sprite = player.get_node("Sprite2D")

func process_impact(angle: float, velocity_y: float):
	if angle >= 45.0:
		_handle_bad_landing(velocity_y)
	else:
		_process_reward(angle)

func _process_reward(error: float):
	var msg = ""
	if error <= 5.0: msg = "PERFECT LANDING!"
	elif error <= 15.0: msg = "NICE LANDING!"
	elif error <= 30.0: msg = "OK LANDING"
	else: msg = "SKETCHY..."
	
	landing_processed.emit(msg, false)

func _handle_bad_landing(impact_vel: float):
	if sprite.has_method("play_bail_flash"):
		sprite.play_bail_flash()
	
	player.current_k = player.base_k
	# Give a stronger Pity Bounce to ensure they clear the ground
	player.velocity.y = -impact_vel * 0.65 
	player.position.y -= 10 # Force them higher so RayCast resets
	
	landing_processed.emit("BAD LANDING!", true)

func get_landing_error() -> float:
	var angle_in_circle = abs(fmod(player.rotation_degrees, 360.0))
	if angle_in_circle > 180:
		angle_in_circle = 360 - angle_in_circle
	return angle_in_circle
