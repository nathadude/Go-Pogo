extends Node2D

signal landing_processed(msg, is_bad)

@onready var player = get_parent()
@onready var sprite = player.get_node("Sprite2D")
@onready var score_label = get_tree().get_first_node_in_group("score_label")

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
	# 1. Visual Flare
	if sprite.has_method("play_bail_flash"):
		sprite.play_bail_flash()
	
	# 2. Physics: BIG Pity Bounce
	# We multiply by 0.8 instead of 0.5 to get them AWAY from the ground
	player.velocity.y = -impact_vel * 0.8 
	player.position.y -= 15 # Physical shove away from floor
	
	# 3. Automation: Force the player back to 0 so they don't loop
	var tween = create_tween()
	tween.tween_property(player, "rotation_degrees", 0, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	landing_processed.emit("BAD LANDING!", true)

func get_landing_error() -> float:
	var angle_in_circle = abs(fmod(player.rotation_degrees, 360.0))
	if angle_in_circle > 180:
		angle_in_circle = 360 - angle_in_circle
	return angle_in_circle
