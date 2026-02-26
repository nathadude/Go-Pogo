extends ColorRect

@onready var final_score_label = $VBoxContainer/FinalScoreLabel
@onready var high_score_label = $VBoxContainer/HighScoreLabel
@onready var new_best_label = $NewBestLabel
@onready var restart_button = $VBoxContainer/RestartButton


func _ready():
	await get_tree().process_frame
	
	GameEvents.game_over_reached.connect(_on_game_over)
	new_best_label.visible = false # Keep hidden by default
	
	restart_button.pressed.connect(_on_restart_pressed)

func _on_game_over(score: int):
	visible = true
	get_tree().paused = true
	
	final_score_label.text = "FINAL SCORE: %d" % score
	
	# THE HIGH SCORE LOGIC
	if score > SaveManager.high_score:
		_trigger_new_best(score)
	else:
		new_best_label.visible = false
		high_score_label.text = "BEST: %d" % SaveManager.high_score

func _trigger_new_best(new_score: int):
	SaveManager.save_new_high_score(new_score)
	
	high_score_label.text = "BEST: %d" % new_score
	new_best_label.visible = true
	
	# Add a little juice to the notification
	var tween = create_tween().set_loops().set_ignore_time_scale(true)
	tween.tween_property(new_best_label, "modulate:a", 0.3, 0.4)
	tween.tween_property(new_best_label, "modulate:a", 1.0, 0.4)


func _on_restart_pressed():
	# 1. Reset Global Engine States FIRST
	Engine.time_scale = 1.0
	get_tree().paused = false
	visible = false
	get_tree().reload_current_scene()
