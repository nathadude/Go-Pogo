extends Label

@export var float_distance := 100.0
@export var fade_duration := 0.8

# We will let the Player find this label and assign itself
var player: CharacterBody2D 

func _ready():
	modulate.a = 0
	horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	# This ensures the label doesn't move with any parent container
	set_as_top_level(true) 

func _on_player_jumped(val: float, has_buckled: bool):
	shout(_get_jump_text(val, has_buckled), _get_jump_color(val, has_buckled))

func _on_landing_processed(msg: String, is_bad: bool):
	shout(msg, Color.DARK_RED if is_bad else Color.WHITE)

func shout(msg: String, color: Color):
	# Safety Check: If player isn't assigned yet, don't shout
	if not player: 
		# Try to find the player one last time
		player = get_tree().get_first_node_in_group("player")
		if not player: return

	var new_label = self.duplicate()
	get_parent().add_child(new_label)
	
	# Position logic
	new_label.text = msg
	new_label.modulate = color
	new_label.modulate.a = 1.0
	new_label.scale = Vector2(0.5, 0.5)
	
	# Set position relative to player
	# not rly workinhg how I want it
	#new_label.global_position = player.global_position + Vector2(-new_label.size.x / 2.5, -100)

	var tween = create_tween().set_parallel(true)
	tween.tween_property(new_label, "position:y", new_label.position.y - float_distance, fade_duration)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(new_label, "modulate:a", 0.0, fade_duration)
	
	var scale_tween = create_tween()
	scale_tween.tween_property(new_label, "scale", Vector2(1.2, 1.2), 0.1)
	scale_tween.tween_property(new_label, "scale", Vector2(1.0, 1.0), 0.1)
	
	tween.chain().finished.connect(new_label.queue_free)

# --- Logic Helpers ---
func _get_jump_text(val: float, has_buckled: bool) -> String:
	if has_buckled: return "LATE!"
	if val >= 100: return "PERFECT!"
	if val >= 95: return "EXCELLENT!"
	if val >= 90: return "GREAT!"
	if val >= 80: return "GOOD!"
	return "EARLY..."

func _get_jump_color(val: float, has_buckled: bool) -> Color:
	if has_buckled: return Color.DARK_RED
	if val >= 100: return Color.GOLD
	if val >= 95: return Color.MAGENTA
	if val >= 90: return Color.CYAN
	if val >= 80: return Color.CYAN
	return Color.WHITE


func _on_feedback_timer_timeout() -> void:
	pass # Replace with function body.
