extends Camera2D

@onready var marker = preload('res://scenes/effects/movement_marker.tscn')
var pivot_camera = Vector2.ZERO
var player :UNIT = preload('res://scenes/units/hero_knight.tscn').instantiate()
@onready var current_spell = null
@onready var world = get_tree().root.get_child(0)


func _ready():
	player.global_position = world.get_node('PlayerSpawnPoint').global_position
	world.add_child(player)
	global_position = player.global_position
	
	

func place_tip_on_ui(text:String, wait_time = 5):
	$Player_UI/Panel/TipLabel.text = text
	if wait_time != 0:
		$Player_UI/Panel/TipLabel/Timer.wait_time = wait_time
		$Player_UI/Panel/TipLabel/Timer.start()
	
func _on_timer_timeout() -> void:
	$Player_UI/Panel/TipLabel.text = ''

	
	
func _physics_process(delta):
	var strenght = 0
	var intelligence = 0
	var agility = 0
	for item in $Player_UI/InventoryContainer/VBoxContainer/Inventory.get_children():
		if item.get_child_count() != 0:
			strenght += item.get_child(0).strenght
			intelligence += item.get_child(0).intelligence
			agility += item.get_child(0).agility
			
	player.inventory_stats['strenght'] = strenght
	player.inventory_stats['intelligence'] = intelligence
	player.inventory_stats['agility'] = agility
	
	if Input.is_action_just_pressed("grab_camera"):
		pivot_camera = get_global_mouse_position()
	if Input.is_action_pressed("grab_camera"):
		var gap = pivot_camera - get_global_mouse_position()
		self.global_position += gap
	if Input.is_action_just_pressed("center_the_camera"):
		global_position = player.global_position
	if Input.is_action_just_pressed("open_close_shop"):
		$Player_UI/ShopContainer.visible = !$Player_UI/ShopContainer.visible
	
func check_target_on_mouse_pos():
	var point = PhysicsPointQueryParameters2D.new()
	point.collide_with_areas = true
	point.collision_mask = 2
	point.position = get_global_mouse_position()
	var select = get_world_2d().direct_space_state.intersect_point(point, 1)
	if select.size():
		return select[0].collider.get_parent()
	return null

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			var m = marker.instantiate()
			var target = check_target_on_mouse_pos()
			if(target):
				if !target.isdead:
					if target.fraction != player.fraction:
						player.set_enemy_target(target)
						player.set_state(player.states.agro)
						m.modulate = '#91050f'
						player.get_enemy_target().add_child(m)
			else:
				player.set_state(player.states.moving)
				player.movement_target = get_global_mouse_position()
				player.nav.target_position = player.movement_target
				world.add_child(m)
				m.global_position = get_global_mouse_position()
		elif event.button_index == MOUSE_BUTTON_LEFT and event.pressed and current_spell:
			var target = check_target_on_mouse_pos()
			if target:
				if current_spell.spell_target_allies and target.fraction == player.fraction:
					var res = current_spell.action(target)
					if res:
						current_spell.start_cooldown()
						current_spell = null
