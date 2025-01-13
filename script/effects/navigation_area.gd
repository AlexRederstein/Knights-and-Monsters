extends Area2D

@onready var dire_base :Vector2 = get_parent().get_parent().get_node('Constructions/Dire/DireBase').get_global_position()
@onready var radiant_base :Vector2 = get_parent().get_parent().get_node('Constructions/Radiant/RadiantBase').get_global_position()

func _on_body_entered(body: UNIT) -> void:
	if !body.ISHERO:
		body.command_mode = body.CommandMode.ATTACK_MOVE
		if body.fraction == 'radiant':
			print(get_parent().get_parent().get_node('Constructions/Dire/DireBase').get_global_position())
			body.movement_target = dire_base
		elif body.fraction == 'dire':
			body.movement_target = radiant_base
			
			
