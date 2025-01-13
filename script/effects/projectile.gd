extends Area2D
var tar :UNIT = null
@onready var tar_position = tar.get_global_position()
var damage :int = 0
var SPEED = 800


func _physics_process(delta: float) -> void:
	if is_instance_valid(tar):
		tar_position = tar.get_global_position()
		var direction = global_position.direction_to(tar_position)
		self.rotation = direction.angle()
		global_position += direction * SPEED * delta
	else:
		queue_free()
	
	#if(get_parent().get_enemy_target()):
		##var degrees = self.get_global_position().direction_to(self.get_parent().get_enemy_target().get_global_position())
		#var direction = global_position.direction_to(tar.global_position).normalized()
		#self.rotation = direction.angle()
		#self.global_position += direction * SPEED * delta
	#else:
		#queue_free()

func _on_body_entered(body: UNIT) -> void:
	if(self.tar == body):
		self.tar.take_damage(self.damage)
		queue_free()
