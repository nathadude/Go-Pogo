extends Area2D

func _ready():
	# Connect using a callable
	self.body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "Player":  # or check body type
		get_tree().reload_current_scene()
