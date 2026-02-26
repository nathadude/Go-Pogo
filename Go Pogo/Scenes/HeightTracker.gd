extends Label

var player: CharacterBody2D
var start_y: float = 0.0
var max_height: float = 0.0
var is_calibrated := false

func _ready():
	# Look for the player when the HUD spawns
	player = get_tree().get_first_node_in_group("player")
	max_height = 0.0

func _process(_delta):
	if not player: 
		player = get_tree().get_first_node_in_group("player")
		return
	
	if not is_calibrated and player.is_on_floor():
		start_y = player.global_position.y
		is_calibrated = true

	if is_calibrated:
		var current_dist = (start_y - player.global_position.y) / 50.0
		current_dist = max(0, current_dist)
		
		if current_dist > max_height:
			max_height = current_dist
		
		text = "ALTITUDE: %.1f m\nRECORD: %.1f m" % [current_dist, max_height]
