extends CanvasLayer


func _on_play_again_pressed() -> void:
	get_tree().reload_current_scene()




func _on_exit_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/world/menu.tscn")
