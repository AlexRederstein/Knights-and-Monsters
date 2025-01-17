extends Camera2D


var pivot_camera = Vector2.ZERO


func _physics_process(delta):
	if Input.is_action_just_pressed("grab_camera"):
		pivot_camera = get_global_mouse_position()
	if Input.is_action_pressed("grab_camera"):
		var gap = pivot_camera - get_global_mouse_position()
		self.global_position += gap
	
