extends Node2D

var Player = preload("res://scenes/units/hero_knight.tscn")
var creeps = {
	'radiant_melee' = preload('res://scenes/units/radiant_melee.tscn'),
	'radiant_range' = preload('res://scenes/units/radiant_range.tscn'),
	'dire_melee' = preload('res://scenes/units/dire_melee.tscn'),
	'dire_range' = preload('res://scenes/units/dire_range.tscn'),
}
@onready var CreepTimer = $'CreepTimer'
func _ready():
	#pass
	spawn_creeps()
func _physics_process(delta: float) -> void:
	pass


func _on_creep_timer_timeout() -> void:
	spawn_creeps()


func spawn_creeps():
	for point in $'Spawners'.get_children():
		var creep = creeps[point.editor_description].instantiate()
		creep.position = point.global_position
		creep.command_mode = creep.CommandMode.ATTACK_MOVE
		add_child(creep)
		if creep.fraction == 'radiant':
			creep.movement_target = self.get_node('Constructions/Dire/DireBase').get_global_position()
		else:
			creep.movement_target = self.get_node('Constructions/Radiant/RadiantBase').get_global_position()
		creep.nav.target_position = creep.movement_target
		creep.call_deferred('set_state', creep.states.moving)
		
#func spawn_lane_creeps(line):
	#for point in line.get_children():
		#var key = point.name.get_slice('_', 0)
		#var creep = creeps[key].instantiate()
		#creep.position = point.global_position
		#self.add_child(creep)
		#creep.command_mode = creep.CommandMode.ATTACK_MOVE
		#creep.movement_target = self.get_node('Navigations/'+line.name).get_global_position()
		#creep.call_deferred('set_state', creep.states.moving)
#
#func spawn_lanes_creeps():
	#for line in $'Spawners'.get_children():
		#spawn_lane_creeps(line)
	#$CreepTimer.start()
