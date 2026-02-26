extends Node

## --- Config ---
@export var base_jump_points := 100
@export var base_landing_points := 250

## --- Internal State ---
@onready var total_score := 0
@onready var multiplier := 1

@onready var ui = get_tree().get_first_node_in_group("score_label")

## --- THE "SHOUT" LISTENERS ---

func _ready():
	# This runs every time the scene reloads IF this node 
	# is a child of the scene. 
	# IF THIS IS AN AUTOLOAD: This only runs ONCE when the game launches.
	reset_score_entirely()

func reset_score_entirely():
	total_score = 0
	multiplier = 1
	# If you track altitude here, reset it too
	# current_altitude = 0 
	
	# Force the UI to update immediately
	_update_ui()

# Called when player launches (accuracy is 0.0 to 1.0)
func register_jump(accuracy: float, is_late: bool):
	if is_late:
		reset_multiplier()
		return
	
	# Score = Base * Accuracy * Multiplier
	var points = int(base_jump_points * accuracy * multiplier)
	_add_to_total(points)

# Called when player lands (error is degrees 0 to 45)
func register_landing(error: float):
	# Quality: 0 deg = 1.0 multiplier, 45 deg = 0.2 multiplier
	var quality = remap(error, 0, 45, 1.0, 0.2)
	var points = int(base_landing_points * quality * multiplier)
	_add_to_total(points)

# Called whenever a 330-degree rotation is completed
func register_trick_completed():
	multiplier += 1
	_update_ui()

# Called on Bad Landings or Buckles
func reset_multiplier():
	multiplier = 1
	_update_ui()

## --- Private Helpers ---

func _add_to_total(amount: int):
	total_score += amount
	_update_ui()

func _update_ui():
	if ui:
		ui.update_display(total_score, multiplier)
		
func _reset_ui():
	if ui:
		ui.update_display(0, 1)
