extends Node

const SAVE_PATH = "user://highscore.save"
var high_score: int = 0

func _ready():
	load_high_score()

func load_high_score():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		high_score = file.get_32() # Reads a single integer
	else:
		high_score = 0

func save_new_high_score(new_score: int):
	high_score = new_score
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_32(high_score)
	
func _input(event):
	if event.is_action_pressed("debug_reset"): # Map this in Input Map
		DirAccess.remove_absolute("user://highscore.save")
		high_score = 0
		print("High score wiped!")
