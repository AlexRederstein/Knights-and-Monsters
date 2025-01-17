extends "res://script/units/unit_entity.gd"
@onready var marker = preload('res://scenes/effects/movement_marker.tscn')

#func _ready() -> void:
	#spawn_point = 

func _input(event):
	if !isdead:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
				var m = marker.instantiate()
				var point = PhysicsPointQueryParameters2D.new()
				point.collide_with_areas = true
				point.collision_mask = 2
				point.position = get_global_mouse_position()
				var select = get_world_2d().direct_space_state.intersect_point(point, 1)
				if(select.size()):
					var target = select[0].collider.get_parent()
					if !target.isdead:
						if target.fraction != self.fraction:
							set_enemy_target(target)
							set_state(states.agro)
							m.modulate = '#91050f'
							get_enemy_target().add_child(m)
				else:
					set_state(states.moving)
					movement_target = get_global_mouse_position()
					nav.target_position = movement_target
					get_parent().add_child(m)
					m.global_position = get_global_mouse_position()
	else:
		return
