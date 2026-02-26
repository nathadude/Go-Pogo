extends RayCast2D

var parent_rotation

func _process(_delta):
	parent_rotation = get_parent().rotation
	set_rotation (- parent_rotation)
