extends Label

var current_score: int = 0
var displayed_score: float = 0.0

func _process(delta):
	# "roll" the displayed score up to the actual score
	# counting visual arcade effect
	if displayed_score < current_score:
		displayed_score = move_toward(displayed_score, current_score, delta * 500)
		text = "SCORE: %06d" % int(displayed_score)

## The main function other scripts will call
func add_score(amount: int):
	current_score += amount
	_punch_animation()

## Visual feedback when points are added
func _punch_animation():
	var tween = create_tween()
	# Scale the label up and back down quickly
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.05)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)
	
	# Flash colors
	var flash_tween = create_tween()
	flash_tween.tween_property(self, "modulate", Color(2, 2, 0), 0.05) # Gold kinda
	flash_tween.tween_property(self, "modulate", Color(1, 1, 1), 0.1)
