extends Label

@onready var timer = $FeedbackTimer # Assumes timer is a child of the label

func _ready():
	text = "" # Clear placeholder text on start

# This is the 'Slot' that waits for the 'Signal'
func _on_player_jumped(val: float, has_buckled: bool):
	text = get_jump_feedback(val, has_buckled)
	_set_label_color(val, has_buckled)
	
	# THE VISUAL BURST: Scale from 0 to 1.5 and back to 1.0
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.5, 1.5), 0.1).set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)
	
	timer.start() 

func get_jump_feedback(val: float, has_buckled: bool) -> String:
	if has_buckled: return "LATE!"
	if val >= 100: return "PERFECT!"
	if val >= 96:  return "EXCELLENT!"
	if val >= 90:  return "GREAT!"
	if val >= 81:  return "NICE!"
	return "EARLY..."

func _set_label_color(val: float, has_buckled: bool):
	if has_buckled: modulate = Color.DARK_RED
	elif val >= 100: modulate = Color.GOLD
	elif val >= 90:  modulate = Color.CYAN
	else: modulate = Color.WHITE

func _on_feedback_timer_timeout():
	text = ""
