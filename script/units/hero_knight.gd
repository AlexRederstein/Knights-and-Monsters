extends "res://script/units/unit_entity.gd"
@onready var marker = preload('res://scenes/effects/movement_marker.tscn')


func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			var m = marker.instantiate()
			var point = PhysicsPointQueryParameters2D.new()
			point.collide_with_bodies = true
			point.collision_mask = 1
			point.position = get_global_mouse_position()
			var select = get_world_2d().direct_space_state.intersect_point(point, 1)
			if(select.size()):
				var target = select[0].collider
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
