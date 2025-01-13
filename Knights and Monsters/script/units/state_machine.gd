extends CharacterBody2D
class_name StateMachine

var state = null
var prev_state = null
var states = {}
var unit = get_parent()

func _physics_process(delta: float) -> void:
	if !self.ISBILDING:
		check_collide_areas(delta)
	if state != null:
		state_logic(delta)
		var transition = get_transition(delta)
		if transition != null:
			set_state(transition)

func check_collide_areas(delta):
	pass
	#for ray in self.get_node('Rays').get_children():
		#if ray.is_colliding():
			#var clear_ray = self.movement.get_clear_direction(self.rays)
			#if(clear_ray):
				#var direction = Vector2.RIGHT.rotated(self.rays.rotation + clear_ray.rotation)
				#velocity = direction * 1000 * delta
				#self.move_and_slide()
				#break

func update_stats(delta = 0) -> void:
	if(self.time_to_next_attack > 0):
		self.time_to_next_attack -= delta
	else:
		self.time_to_next_attack = 0
	if !self.ISBILDING:
		if(self.ISHERO):
			self.MAX_HP = self.DEFAULT_HP + (self.strenght * 3)
			self.HP_recovery = 0.25 + (self.strenght * 0.03)
			self.MAX_MANA = self.DEFAULT_MANA + (self.intelligence * 13)
			self.MANA_recovery = 0.25 + (self.intelligence * 0.04)
		if(self.HP < self.MAX_HP):
			self.HP += self.HP_recovery * delta
		else:
			self.HP = self.MAX_HP
		if(self.MANA < self.MAX_MANA):
			self.MANA += self.MANA_recovery * delta
		else:
			self.MANA = self.MAX_MANA
	self.damage = self.DEFAULT_DAMAGE + self.strenght
	self.hp_bar.max_value = self.MAX_HP
	self.hp_bar.value = self.HP
	self.mana_bar.max_value = self.MAX_MANA
	self.mana_bar.value = self.MANA



func state_logic(delta):
	pass
	
func get_transition(delta):
	pass

func set_state(transition):
	if transition == state:
		return
	prev_state = state
	state = transition
	#if prev_state != null:
		#exit_state()
	#if state != null:
		#enter_state()

func enter_state():
	pass
	
func exit_state():
	pass
	
func add_state(state_name):
	states[state_name] = states.size()
	
	
	
