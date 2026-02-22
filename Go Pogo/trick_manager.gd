extends Node2D

signal multiplier_changed(new_value)

@export var rotation_speed := 400.0 
@export var trick_multiplier_increment := 0.5

var current_multiplier := 1.0
var total_rotation_this_jump := 0.0
var is_trick_animating := false # Used for the "tap" trick

@onready var player = get_parent()

func _process(delta):
	# The Player.gd script toggles "can_trick" based on the RayCast
	if not player.is_on_floor() and player.can_trick:
		if Input.is_action_pressed("move_up") and not is_trick_animating:
			_handle_rotation_input(delta)

func _handle_rotation_input(delta):
	var rotation_step = rotation_speed * delta
	player.rotation_degrees += rotation_step
	total_rotation_this_jump += rotation_step
	
	# Every full 360 rotation boosts the multiplier
	if total_rotation_this_jump >= 360.0:
		current_multiplier += trick_multiplier_increment
		total_rotation_this_jump -= 360.0 
		multiplier_changed.emit(current_multiplier)

## Sonic Rush Style "Tap" Trick (Optional: Call this from Player.gd if you prefer taps)
func perform_midair_trick(sprite: Sprite2D):
	if is_trick_animating: return 
	
	is_trick_animating = true
	current_multiplier += 0.5
	multiplier_changed.emit(current_multiplier)
	
	var tween = create_tween()
	tween.tween_property(sprite, "rotation_degrees", player.rotation_degrees + 360, 0.4).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	tween.finished.connect(func(): is_trick_animating = false)

func reset_multiplier(pay_out: bool):
	if pay_out:
		# Logic for adding to score would go here
		pass
	
	current_multiplier = 1.0
	total_rotation_this_jump = 0.0
	multiplier_changed.emit(current_multiplier)
