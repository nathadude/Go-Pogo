extends Label

@onready var player = get_tree().get_first_node_in_group("player")
var start_y : float = 0.0
var max_height : float = 0.0
var is_calibrated := false
#var parent_rotation
#var parent_position

func _process(_delta):
	
	#counteract parent node movement to anchor label...until UI is refactored
	#parent_rotation = get_parent().rotation
	#parent_position = get_parent().position
	#set_rotation (- parent_rotation)
	#set_position(- parent_position)
	
	if not player: return
	
	# CALIBRATION: Wait for the first time the player hits the ground
	if not is_calibrated:
		if player.is_on_floor():
			start_y = player.global_position.y
			is_calibrated = true
		text = "ALT: 0.0 m" # Keep it at zero while falling the first time
		return

	# Calculate distance upwards relative to the starting floor
	var current_dist = (start_y - player.global_position.y) / 50.0 
	current_dist = max(0, current_dist) # Prevents negative if they fall below start
	
	if current_dist > max_height:
		max_height = current_dist
	
	text = "ALT: %.1f m\nMAX: %.1f m" % [current_dist, max_height]
