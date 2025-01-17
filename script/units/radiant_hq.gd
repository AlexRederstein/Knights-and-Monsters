extends UNIT

func die():
	get_tree().get_root().get_children()[0].end_game(false)
	queue_free()
