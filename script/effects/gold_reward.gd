extends Label




func _on_animation_player_animation_changed(old_name: StringName, new_name: StringName) -> void:
	queue_free()


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	queue_free()
