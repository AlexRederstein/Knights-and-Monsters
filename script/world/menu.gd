extends CanvasLayer

func _ready():
	get_tree().paused = false
	

func _on_quit_pressed():
	get_tree().quit()


func _on_play_pressed():
	get_tree().change_scene_to_file("res://scenes/world/world.tscn")
