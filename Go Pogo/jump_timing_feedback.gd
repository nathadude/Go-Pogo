extends Label

@onready var timer = $FeedbackTimer

func _ready():
	text = ""
	pivot_offset = size / 2 # Ensures the burst scales from the center

## CONNECT THIS TO PLAYER "jumped" SIGNAL
func _on_player_jumped(val: float, has_buckled: bool):
	text = _get_jump_text(val, has_buckled)
	_set_color(has_buckled, val >= 100)
	_burst_animate()

## CONNECT THIS TO LANDING_MANAGER "landing_processed" SIGNAL
func _on_landing_processed(msg: String, is_bad: bool):
	text = msg
	modulate = Color.DARK_RED if is_bad else Color.WHITE
	_burst_animate()

func _get_jump_text(val: float, has_buckled: bool) -> String:
	if has_buckled: return "LATE!"
	if val >= 100: return "PERFECT!"
	if val >= 96: return "EXCELLENT!"
	if val >= 90: return "GREAT!"
	if val >= 81: return "NICE!"
	return "EARLY..."

func _set_color(is_bad: bool, is_perfect: bool):
	if is_bad: modulate = Color.DARK_RED
	elif is_perfect: modulate = Color.GOLD
	else: modulate = Color.WHITE

func _burst_animate():
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.5, 1.5), 0.1).set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)
	timer.start()

func _on_feedback_timer_timeout():
	text = ""


func _on_landing_manager_landing_processed(msg: Variant, is_bad: Variant) -> void:
	pass # Replace with function body.
