extends Label

var current_score: int = 0
var current_mult: int = 1
var displayed_score: float = 0.0

func _ready():
	current_score = 0
	current_mult = 1
	displayed_score = 0.0

func _process(delta):
	if displayed_score < current_score:
		# Satisfying number roll
		displayed_score = move_toward(displayed_score, current_score, delta * 1000)
	
	# THE FIX: Always include the multiplier in the string
	# Use [b] or color tags if you have 'RichTextLabel', otherwise standard string:
	text = "SCORE: %06d\nMULT: x%d" % [int(displayed_score), current_mult]

func update_display(score: int, mult: int):
	current_score = score
	
	# Only "Punch" the UI if the multiplier increased
	if mult > current_mult:
		_multiplier_up_effect()
	
	current_mult = mult

func _multiplier_up_effect():
	var tween = create_tween().set_parallel(true)
	# Quick scale punch to show the level-up
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.1)
	tween.tween_property(self, "modulate", Color(1, 0.8, 0), 0.1) # Gold flash
	
	tween.chain().tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)
	tween.tween_property(self, "modulate", Color(1, 1, 1), 0.1)
