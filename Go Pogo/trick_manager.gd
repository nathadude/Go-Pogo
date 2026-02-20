extends Node2D

## Signals to talk to the rest of the game
signal trick_completed(trick_name, score_value)
signal rotation_updated(current_total)

@export var leeway := 15.0
@export var rotation_threshold := 360 - leeway # Degrees for a "full" flip (with 30d of leeway)

var total_rotation := 0.0
var last_frame_rotation := 0.0
var is_tracking := false

@warning_ignore("unused_parameter") #not sure what this is yet
func _process(delta):
	var parent = get_parent()
	
	if not parent.is_on_floor():
		if not is_tracking:
			_start_tracking(parent.rotation_degrees)
		
		_update_rotation(parent.rotation_degrees)
	else:
		if is_tracking:
			_finalize_trick()

func _start_tracking(start_rot):
	is_tracking = true
	total_rotation = 0.0
	last_frame_rotation = start_rot

func _update_rotation(current_rot):
	# Calculate the delta rotation between frames
	var frame_diff = current_rot - last_frame_rotation
	
	# Handle the 180 to -180 wrap-around jump if necessary
	if frame_diff > 180: frame_diff -= 360
	if frame_diff < -180: frame_diff += 360
	
	total_rotation += abs(frame_diff)
	last_frame_rotation = current_rot
	rotation_updated.emit(total_rotation)

func _finalize_trick():
	is_tracking = false
	
	# Determine how many flips were completed
	var flip_count = int(total_rotation / 360)
	
	if total_rotation >= rotation_threshold:
		var score = flip_count * 100
		var trick_name = str(flip_count) + "x FLIP!" if flip_count > 1 else "FLIP!"
		trick_completed.emit(trick_name, score)
	
	total_rotation = 0.0
