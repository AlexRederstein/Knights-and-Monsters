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
@onready var inventory = camera.get_node('Player_UI/InventoryContainer/VBoxContainer/Inventory')
@onready var time = 0


func _ready():
	get_tree().paused = false
	add_child(camera)
	spawn_creeps()
	$GameTimer.timeout.connect(_on_game_timer_timeout)
	
# ===============================================
# =================== PROCESS ===================
# ===============================================

func _physics_process(delta: float) -> void:
	pass


# ===============================================
# ===============================================
# ===============================================

func buy_item(shop_item):
	if camera.player.current_gold >= shop_item.price:
		for slot in inventory.get_children():
			if slot.get_child_count() == 0:
				var item = shop_item.duplicate()
				item.get_node('PanelContainer').visible = false
				item.inshop = false
				slot.add_child(item)
				camera.player.current_gold -= shop_item.price
				break
	else:
		camera.place_tip_on_ui('Недостаточно золота')

func sell_item(item):
	camera.player.get_extra_reward(item.price / 2)
	item.queue_free()

	
#func show_slot():
	#print(inventory.get_child(0).get_children())



func start_player_death_countdown():
	camera.player.visible = false
	camera.player.global_position = $PlayerSpawnPoint.global_position
	camera.player.movement_target = camera.player.global_position
	camera.player.enemy_target = null
	
	$PlayerDeathTimer.wait_time = 4 + 6 * camera.player.current_level
	$PlayerDeathTimer.start()
	camera.get_node('Player_UI/DeathTimerControl').visible = true
	
func _on_player_death_timer_timeout() -> void:
	camera.player.isdead = false
	camera.player.hp = camera.player.max_hp
	camera.player.set_state(camera.player.states.idle)
	camera.player.visible = true
	
	camera.get_node('Player_UI/DeathTimerControl').visible = false
	camera.global_position = camera.player.global_position


func _on_game_timer_timeout() -> void:
	time += 1
	var minutes = floor(time / 60)
	var seconds = floor(time % 60)
	camera.get_node('Player_UI/TimerContainer/Timer').text = str("%02d:%02d" % [minutes, seconds])
	camera.player.current_gold += 1

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
