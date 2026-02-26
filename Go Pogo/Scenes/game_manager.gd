extends Node

signal game_over(final_score)

@export var session_time := 60.0 # Seconds
var time_left := 0.0
var is_active := true

@onready var score_manager = get_tree().get_first_node_in_group("score_manager")
@onready var timer_label = get_tree().get_first_node_in_group("timer_label")

func _ready():
	#reset everything
	Engine.time_scale = 1.0
	get_tree().paused = false 
	time_left = session_time
	is_active = true
	
	if get_tree().root.has_node("ScoreManager"):
		var sm = get_tree().root.get_node("ScoreManager")
		sm.total_score = 0
		sm.multiplier = 1
	
	var label = get_tree().get_first_node_in_group("score_label")
	if label:
		label.text = "SCORE: 000000\nx1"
		if "displayed_score" in label:
			label.displayed_score = 0 # Stop the 'roll' from the old score

func _process(delta):
	if not is_active: return
	
	time_left -= delta
	_update_timer_ui()
	
	if time_left <= 0:
		_end_session()

func _update_timer_ui():
	if timer_label:
		timer_label.text = "TIME: %d" % ceil(time_left)
	if time_left <= 10:
		timer_label.modulate = Color.RED
		# Subtle shake effect
		timer_label.position.x += randf_range(-1, 1) 
	else:
		timer_label.modulate = Color.WHITE

func _end_session():
	if not is_active: return
	is_active = false
	
	# 1. Create the slowdown effect
	var tween = create_tween()
	
	tween.set_ignore_time_scale(true)
	
	# CRITICAL: This ensures the tween itself doesn't slow down 
	# while it's trying to slow down the engine!
	tween.set_speed_scale(1.0) 
	
	# Tween the engine's time scale to zero over 0.5 seconds
	tween.tween_property(Engine, "time_scale", 0.0, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	#tween.tween_property(music_player, "pitch_scale", 0.1, 0.5)
	
	await tween.finished #stuck here, tween never finishes SOLVED line 41
	
	# 3. Emit the signal to show the Game Over screen
	var final_score = 0
	if score_manager:
		final_score = score_manager.total_score
		
	GameEvents.game_over_reached.emit(final_score)
