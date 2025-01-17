extends Node2D

var Player = preload("res://scenes/units/hero_knight.tscn")
var creeps = {
	'radiant_melee' = preload('res://scenes/units/radiant_melee.tscn'),
	'radiant_range' = preload('res://scenes/units/radiant_range.tscn'),
	'dire_melee' = preload('res://scenes/units/dire_melee.tscn'),
	'dire_range' = preload('res://scenes/units/dire_range.tscn'),
}
@onready var CreepTimer = $'CreepTimer'
@onready var camera = preload('res://scenes/effects/player_ui.tscn').instantiate()
@onready var player = preload('res://scenes/units/hero_knight.tscn').instantiate()


func _ready():
	get_tree().paused = false
	player.global_position = $'PlayerSpawnPoint'.global_position
	add_child(player)
	camera.global_position = player.global_position
	add_child(camera)
	spawn_creeps()
	
	
	
func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("center_the_camera"):
		camera.global_position = player.global_position

func start_player_death_countdown():
	player.visible = false
	player.position = $'PlayerSpawnPoint'.position
	$PlayerDeathTimer.wait_time = 4 + 6 * player.current_level
	$PlayerDeathTimer.start()
	camera.get_node('Player_UI/DeathTimerControl').visible = true
	
func _on_player_death_timer_timeout() -> void:
	player.isdead = false
	player.hp = player.max_hp
	player.movement_target = player.global_position
	player.enemy_target = null
	player.set_state(player.states.idle)
	
	player.visible = true
	camera.get_node('Player_UI/DeathTimerControl').visible = false
	camera.global_position = player.global_position

func end_game(is_victory :bool = true ):
	get_tree().paused = true
	var endGameScreen = preload('res://scenes/effects/end_game.tscn').instantiate()
	if is_victory:
		endGameScreen.get_node('Control/PanelContainer/MarginContainer/VBoxContainer/Label').text = 'ПОБЕДА'
	else:
		endGameScreen.get_node('Control/PanelContainer/MarginContainer/VBoxContainer/Label').text = 'ПОРАЖЕНИЕ'
	add_child(endGameScreen)


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
