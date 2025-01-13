extends StateMachine
class_name UNIT





# Игровые переменные
@export_category('Базовые переменные')
@export var fraction = 'radiant'
@export var isbilding = false
@export var attack_type = 'melee'
@export var invicible = false
@export var range_attack_projectile :PackedScene

@export var SPEED:int = 3000 
@export var default_damage = 0
@export var default_hp = 0

#======================================================================

@export_category('HERO STATS')
@export var ishero = false

#======================================================================
@onready var damage = default_damage
@onready var max_hp = default_hp
@onready var hp = max_hp
#======================================================================

# Технические переменные
@onready var isdead = false

@onready var nav :NavigationAgent2D = $NavigationAgent2D
@onready var enemy_target :WeakRef = null
@onready var movement_target :Vector2 = Vector2.ZERO
@onready var avoidance_pos :Vector2
@onready var path_timer :Timer = $PathCalculateTimer
@onready var anim :AnimatedSprite2D = $AnimatedSprite2D
@onready var rays :Node2D = $Rays2
@onready var ray_top = $Rays2/TopFront
@onready var ray_bottom = $Rays2/BottomFront

#@onready var rays :Node2D = $Rays
#@onready var ray_front :RayCast2D = $Rays/Front
#@onready var ray_front1 :RayCast2D = $Rays/Front2
#@onready var ray_front2 :RayCast2D = $Rays/Front3


#======================================================================


enum CommandMode {
	NONE,
	ATTACK_MOVE
}
var command_mode = CommandMode.NONE


#======================================================================



func _ready():
	add_state('idle')
	add_state('moving')
	add_state('agro')
	add_state('avoid')
	call_deferred('set_state', states.idle)
	init()
	anim.animation_finished.connect(animation_changed)

func animation_changed():
	if anim.animation == 'death':
		queue_free()
	else:
		if(get_enemy_target()):
			print('attack')
			if attack_type == 'melee':
				get_enemy_target().take_damage(damage)
			else:
				range_attack()
			reload_attack()

func init():
	draw_border_for_area2d(self, '#ffffff32')
	if isbilding:
		nav.avoidance_enabled = false
		var obstacle :NavigationObstacle2D = NavigationObstacle2D.new()
		obstacle.radius = 25
		add_child(obstacle)


func draw_border_for_area2d(area2d, color = '#000000'):
	var line = Line2D.new()
	line.width = 1
	line.default_color = color
	var radius = area2d.get_node('CollisionShape2D').get_shape().radius
	var segments = 64
	var angle_step = 2 * PI / segments
	var points = []
	for i in range(segments + 1):
		var angle = i * angle_step
		var x = cos(angle) * radius
		var y = sin(angle) * radius
		points.append(Vector2(x, y))
	line.points = points
	add_child(line)

#======================================================================
#============================== PROCESS ===============================
#======================================================================


func _physics_process(delta: float) -> void:
	boot_hp_bar()
	if isdead:
		return
	match state:
		states.idle:
			if !ishero:
				search_enemy()
				anim.play('idle')
		states.moving:
			if command_mode == CommandMode.ATTACK_MOVE:
				#enemy_target = null
				search_enemy()
			move_to(movement_target, delta)
		states.agro:
			if get_enemy_target():
				if isbilding:
					if in_attack_range():
						if $Attacktimer.is_stopped():
							range_attack()
							reload_attack()
				else:
					if in_attack_range():
						#move_to(get_global_position(), delta)
						#stop()
						if $Attacktimer.is_stopped():
							anim.play('attack_'+get_animation_direction(global_position.direction_to(get_enemy_target().get_global_position())))
						else:
							anim.play('attack_'+get_animation_direction(global_position.direction_to(get_enemy_target().get_global_position())))
							anim.stop()
					else:
						move_to(get_enemy_target().get_global_position(), delta)
		states.avoid:
			move_to(avoidance_pos, delta)

func boot_hp_bar():
	$HpBar.max_value = max_hp
	$HpBar.value = hp

#func play_animation(animation):
	#if isbilding:
		#return
	#anim.play(animation)


#======================================================================
#============================== MOVEMENT ==============================
#======================================================================


func move_to(point:Vector2, delta):
	if path_timer.is_stopped():
		update_path(point)
	if nav.is_navigation_finished():
		if state == states.avoid:
			#set_state(states.moving)
			#print(prev_state, state)
			#avoidance_pos = Vector2.ZERO
			set_state(prev_state)
		return
		#stop()
	else:
		var direction = get_global_position().direction_to(nav.get_next_path_position())
		rays.rotation = direction.angle()
		
#		Тесты обхода препятствий
		#if ray_front.is_colliding() or ray_front1.is_colliding() or ray_front2.is_colliding():
			#var ray = get_clear_direction()
			#if ray:
				#direction = Vector2.RIGHT.rotated(rays.rotation + ray.rotation)
#======================================================================
		var ray = check_collide()
		if ray:
			avoidance_pos = ray.to_global(ray.target_position)
			set_state(states.avoid)
			#move_to(avoidance_pos, delta)
			
			#return
			#nav.target_position = avoidance_pos
			#var marker = preload('res://scenes/effects/movement_marker.tscn')
			#var m = marker.instantiate()
			#m.global_position = avoidance_pos
			#get_parent().add_child(m)
			
		var safe_velocity = SPEED * direction * delta
		nav.set_velocity(safe_velocity)
		anim.play('walk_'+get_animation_direction(direction))
		move_and_slide()


func check_collide():
	var ray
	if ray_top.is_colliding():
		ray = get_clear_direction(rays.get_node('Bottom'))
		return ray
	elif ray_bottom.is_colliding():
		ray = get_clear_direction(rays.get_node('Top'))
		return ray
	return false

func update_path(point:Vector2):
	nav.target_position = point
	path_timer.start()

func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
	

#func get_clear_direction():
	#for ray in rays.get_children():
		#if(!ray.is_colliding()):
			#return ray
	#return null

func get_clear_direction(node:Node2D):
	for ray in node.get_children():
		if(!ray.is_colliding()):
			return ray
	return null


func stop():
	#movement_target = get_global_position()
	nav.target_position = get_global_position()
	#set_state('idle')

func get_animation_direction(degrees: Vector2) -> String:
	var angle = atan2(degrees.y, degrees.x) * 180/PI
	if(abs(angle) > 90):
		anim.flip_h = true
	else:
		anim.flip_h = false
	if(0 < abs(angle) and abs(angle) < 30 or 150 < abs(angle) and abs(angle) < 180):
		return 'e'
	if(30 < angle and angle < 60 or 120 < angle and angle < 150):
		return 'se'
	if(60 < angle and angle < 120):
		return 's'
	if(-30 > angle and angle > -60 or -120 > angle and angle > -150):
		return 'ne'
	if(-60 > angle and angle > -120):
		return 'n'
	return 'n'

#======================================================================
#==============================  ATTACK  ==============================
#======================================================================


func set_enemy_target(target:UNIT):
	enemy_target = weakref(target)
	set_state(states.agro)

func get_enemy_target() -> UNIT:
	if(self.enemy_target != null):
		return self.enemy_target.get_ref()
	return null

func in_attack_range() -> bool:
	for unit in $attack_area.get_overlapping_bodies():
		if unit == get_enemy_target():
			return true
	return false

func range_attack():
	var p = range_attack_projectile.instantiate()
	p.tar = get_enemy_target()
	p.damage = damage
	add_child(p)

func reload_attack():
	$Attacktimer.start()

func take_damage(dmg):
	if !invicible:
		hp -= dmg
		if hp <= 0:
			die()
	
func die():
	isdead = true
	if isbilding:
		queue_free()
	else:
		anim.play('death')

func search_enemy():
	for unit in $guard_area.get_overlapping_bodies():
		if unit.fraction != fraction:
			set_enemy_target(unit)

func _on_guard_area_body_exited(body: Node2D) -> void:
	if(body == self.get_enemy_target()):
		print('target_is_gone')
		self.enemy_target = null
		if command_mode == CommandMode.ATTACK_MOVE:
			nav.target_position = movement_target
			set_state(states.moving)
		else:
			set_state(states.idle)
		#move_to(get_global_position(), 0)

#======================================================================
#======================================================================
#======================================================================
	
	
#
#
#enum Commands {
	#NONE,
	#MOVE,
	#ATTACK_MOVE,
	#HOLD
#}
#var command = Commands.NONE
##COMMAND_MODIFIRES
#var attack_move = false

#
##BASE STATS
#@export_category('Base stats')
#@export var unit_name = 'default'
#@export var SPEED = 100.0
#@export var DEFAULT_HP = 100.0
#@export var DEFAULT_MANA = 0
#@export var HP_recovery = 0.25
#@export var MANA_recovery = 0.0
#@export var ARMOR = 0
#@export var DEFAULT_DAMAGE = 0
#@export var invicible = false
#var reward_experience = 0
#var MAX_HP = 0.0
#var HP = 0
#var MAX_MANA = 0
#var MANA = 0
#
##FRACTION
#@export_category('Fraction')
#@export var fraction = 'radiant'
#
##BOOLS
#@export_category('Bilding')
#@export var ISBILDING = false
#
##HERO STATS
#@export_category('Hero stats')
#@export var ISHERO = false
#var current_level = 1
#var experience_for_next_level = 100
#var current_experience = 0
#@export var strenght = 0
#@export var intelligence = 0
#@export var agility = 0
#@export var increase_strenght = 0
#@export var increase_intelligence = 0
#@export var increase_agility = 0
##ATTACK
#@export_category('Attack')
#var damage = DEFAULT_DAMAGE
#@export var default_attack_speed = 1.0
#var attack_speed = default_attack_speed
#@export var attack_delay = 1.70
#var time_to_next_attack = 0
#
##ONREADY AND NODES
#@onready var isdead = false
#@onready var in_attack_range = false
#@onready var enemy_target = null
#@onready var marker = preload('res://scenes/effects/movement_marker.tscn')
#@onready var anim = $AnimatedSprite2D
#@onready var sprite = $AnimationPlayer
#@onready var nav :NavigationAgent2D = $NavigationAgent2D
#@onready var timer = $Timer
#@onready var rays = $Rays
#@onready var ray_front = $Rays/Front
#@onready var ray_front2 = $Rays/Front2
#@onready var ray_front3 = $Rays/Front3
#@onready var hp_bar = $ProgressBar
#@onready var mana_bar = $'ProgressBar2'
#@export var projectile :PackedScene
#
#signal unit_collided
##COLLISON
#var collision_position :Vector2 = Vector2.ZERO
#var collide_target :UNIT
#
##MOVEMENT
#var movement_target = Vector2.ZERO
#
#func _ready():
	#if not self.ISHERO:
		#self.init_creep()
	#self.nav.max_speed = self.SPEED
	#add_state('idle')
	#add_state('moving')
	#add_state('agro')
	#add_state('attacking')
	#add_state('dying')
	#call_deferred('set_state', states.idle)
	#
	#
	#anim.z_index = 1
	#if $SelectArea/CollisionShape2D.shape == null:
		#$SelectArea/CollisionShape2D.shape = CircleShape2D.new()
		#$SelectArea/CollisionShape2D.shape.radius = 24
	##print($SelectArea/CollisionShape2D.shape)
	#draw_border_for_area2d('SelectArea', '#ffffff32')
	#
	#self.MAX_HP = self.DEFAULT_HP
	#self.MAX_MANA = self.DEFAULT_MANA
	#update_stats()
	#self.HP = self.MAX_HP
	#self.MANA = self.MAX_MANA
	#
	#self.hp_bar.max_value = self.MAX_HP
	#self.hp_bar.value = self.HP
	#self.mana_bar.max_value = self.MAX_MANA
	#self.mana_bar.value = self.MANA
#
#func init_creep():
	#if self.ISBILDING:
		#match self.unit_name:
			#'tower':
				#draw_border_for_area2d('guard_area')
				#$guard_area/CollisionShape2D.shape.radius = 256
				#$attack_area/CollisionShape2D.shape.radius = $guard_area/CollisionShape2D.shape.radius
				#self.DEFAULT_HP = 1500
				#self.DEFAULT_DAMAGE = 150
			#'barrack':
				#$guard_area/CollisionShape2D.disabled = true
				#self.DEFAULT_HP = 2000
			#'base':
				#$guard_area/CollisionShape2D.disabled = true
				#self.DEFAULT_HP = 3000
		#self.SPEED = 0
		#self.HP_recovery = 0
	#else:
		#$guard_area/CollisionShape2D.shape.radius = 200
		#match self.unit_name:
			#'line_melee_creep':
				#self.DEFAULT_HP = 500.0
				#self.DEFAULT_DAMAGE = 20
				#self.reward_experience = 30
				#$attack_area/CollisionShape2D.shape.radius = 60
			#'line_range_creep':
				#self.DEFAULT_HP = 300.0
				#self.DEFAULT_DAMAGE = 25
				#self.reward_experience = 50
				#$attack_area/CollisionShape2D.shape.radius = 150
#
#
#
#
## ========================== ATTACK =================================
#
#func attack():
	#if self.get_enemy_target():
		#if !self.ISBILDING:
			#self.sprite.play('attack_'+self.get_animation_direction(self.get_global_position().direction_to(self.get_enemy_target().get_global_position())))
		#else:
			#self.range_attack()
			#self.reload_attack()
#
#func calculate_damage(target):
	#return self.damage
#
#func range_attack():
	#if(self.get_enemy_target()):
		#var a = self.projectile.instantiate()
		#a.tar = self.get_enemy_target()
		#a.damage = self.calculate_damage(self.get_enemy_target())
		#self.add_child(a)
#
#func reload_attack():
	#self.time_to_next_attack = self.attack_delay
#
#
#func on_melee_hit():
	#if(self.get_enemy_target()):
		#self.get_enemy_target().take_damage(self.calculate_damage(self.get_enemy_target()))
#
#func is_target_in_range_attack() -> bool:
	#for area in $attack_area.get_overlapping_areas():
		#if self.get_enemy_target() == area.get_parent():
			#return true
	#return false
#
#
#
## ========================== STATE LOGIC =================================
#
#
#
#func state_logic(delta):
	#if $PathCalculateTimer.time_left == 0:
		#$PathCalculateTimer.stop()
	#if state != states.dying:
		#update_stats(delta)
	#match state:
		#states.idle:
			#if $guard_area/CollisionShape2D.disabled == false:
				#if !self.ISHERO:
					#print('idle')
					#if !self.get_enemy_target():
						#self.search_enemy()
			#anim.play('idle')
		#states.moving:
			#if self.command_mode == CommandMode.ATTACK_MOVE:
				#self.enemy_target = null
				#self.search_enemy()
			#self.move_to(self.movement_target, delta)
		#states.agro:
			#if self.get_enemy_target() and !self.get_enemy_target().isdead:
				#
				#if self.is_target_in_range_attack():
					#if self.time_to_next_attack == 0:
						#return self.attack()
					#elif !self.ISBILDING:
						#self.stare_at(self.get_enemy_target().get_global_position())
				#else:
					#if !ISHERO:
						#print('move')
					##self.nav.target_position = self.get_enemy_target().get_global_position()
					#move_to(self.get_enemy_target().get_global_position(), delta)
			#else:
				#self.set_state(states.idle)
		#states.attacking:
			#print('attack')
		#states.dying:
			#if !self.ISBILDING:
				#self.isdead = true
				#self.hp_bar.visible = false
				#self.sprite.play('death')
			#else:
				#self.died()
#
#func drop_exp():
	#for unit in $'ExpArea'.get_overlapping_bodies():
		#if unit.ISHERO and unit.fraction != self.fraction:
			##print(unit)
			#pool_exp(unit, self.reward_experience)
			##unit.current_experience += self.reward_experience
		##print(unit)
#
#func pool_exp(unit, reward):
	#unit.current_experience += reward
	#if unit.current_experience >= unit.experience_for_next_level:
		##unit.level_up()
		#unit.current_level += 1
		#unit.intelligence += unit.increase_intelligence
		#unit.strenght += unit.increase_strenght
		#unit.agility += unit.increase_agility
#
		#unit.current_experience -= unit.experience_for_next_level
		#unit.experience_for_next_level = unit.experience_for_next_level / 100 * 130
#
#
#
#
#
#
#
#func stare_at(point: Vector2):
	#self.anim.play('attack'+self.get_animation_direction(self.global_position.direction_to(point)))
	#self.anim.stop()
#
#func get_animation_direction(degrees: Vector2) -> String:
	#var angle = atan2(degrees.y, degrees.x) * 180/PI
	#if(abs(angle) > 90):
		#anim.flip_h = true
	#else:
		#anim.flip_h = false
	#if(0 < abs(angle) and abs(angle) < 30 or 150 < abs(angle) and abs(angle) < 180):
		#return 'e'
	#if(30 < angle and angle < 60 or 120 < angle and angle < 150):
		#return 'se'
	#if(60 < angle and angle < 120):
		#return 's'
	#if(-30 > angle and angle > -60 or -120 > angle and angle > -150):
		#return 'ne'
	#if(-60 > angle and angle > -120):
		#return 'n'
	#return 'n'
#
#
#func set_enemy_target(target: UNIT):
	#self.enemy_target = weakref(target)
	#self.set_state(states.agro)
	#

#
#func search_enemy():
	#var targets_array = []
	#for unit in $guard_area.get_overlapping_bodies():
		#if(unit.fraction != self.fraction and !unit.isdead):
			#targets_array.append(unit)
	#if(targets_array.size()):
		#self.set_enemy_target(self.get_closest_target(targets_array)[0].unit)
		#
#func get_closest_target(arr):
	#var sorted = []
	#for unit in arr:
		#sorted.append({
			#'unit': unit,
			#'distance': self.global_position.distance_to(unit.global_position)
		#})
		#sorted.sort_custom(compare_distance)
		#return sorted
		#
#func compare_distance(a,b):
	#return a.distance < b.distance
	#

#
#
	#
#func draw_border_for_area2d(area2d :String, color = '#000000'):
	#var line = Line2D.new()
	#line.width = 1
	#line.default_color = color
	#var radius = self.get_node(area2d).get_node('CollisionShape2D').get_shape().radius
	#var segments = 64
	#var angle_step = 2 * PI / segments
	#var points = []
	#for i in range(segments + 1):
		#var angle = i * angle_step
		#var x = cos(angle) * radius
		#var y = sin(angle) * radius
		#points.append(Vector2(x, y))
	#line.points = points
	#self.add_child(line)
#
#func take_damage(damage):
	#if !self.invicible:
		#self.HP -= damage
		#if(self.HP <= 0):
			#self.set_state(states.dying)
#
#func died():
	#self.drop_exp()
	#self.queue_free()
#
#
#
#
#
#
#
#
#
## ========================== MOVEMENT =================================
#func _on_path_calculate_timer_timeout():
	#$PathCalculateTimer.stop()
#

#
#func move_to(point: Vector2, delta):
	#if $PathCalculateTimer.is_stopped():
		#nav.target_position = point
		#$PathCalculateTimer.start()
	#if self.nav.is_navigation_finished():
		#return
	#else:
		##if state == states.agro and get_node('PathCalculateTimer').is_stopped():
		#
			##get_node('PathCalculateTimer').start()
		#var target_global_position = self.nav.get_next_path_position()
		#var direction = global_position.direction_to(target_global_position)
		##anim.play('walk_'+get_animation_direction(direction))
		#var safe_velocity = direction * nav.max_speed * delta
		#nav.set_velocity(safe_velocity)
		#
#func get_clear_direction(rays):
	#for ray in rays.get_children():
		#if(!ray.is_colliding()):
			#return ray
	#return null
#
#func stop():
	##if !self.ISHERO:
		##print(self.state)
	#self.command_mode = self.CommandMode.NONE
	#self.movement_target = self.get_global_position
	##self.nav.target_position = self.movement_target
	#self.set_state(self.states.idle)
#
#
#
#
#
#
#
#
#
##func _on_select_area_area_entered(area: Area2D) -> void:
	##if area.name == 'SelectArea' and !area.get_parent().ISBILDING:
		##var direction = self.get_global_position().direction_to(area.get_parent().get_global_position()).rotated(180)
		##velocity = direction * 100
		##self.move_and_slide()
	##print(area.name)
