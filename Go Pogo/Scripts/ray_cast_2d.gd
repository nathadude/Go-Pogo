extends RayCast2D

var parent_rotation

func _process(delta):
	parent_rotation = get_parent().rotation
	set_rotation (- parent_rotation)
