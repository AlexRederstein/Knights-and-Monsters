extends CharacterBody2D

var SPEED = 5000
@onready var movement_target = Vector2.ZERO
@onready var nav:NavigationAgent2D = $NavigationAgent2D
@onready var timer:Timer = $Timer

func _ready():
	nav.max_speed = SPEED
	timer.timeout.connect(update_path)
	nav.velocity_computed.connect(move_to)

func update_path():
	self.nav.target_position = movement_target
	
func move_to(velocity):
	move_and_slide()


func _physics_process(delta: float) -> void:
	if self.nav.is_navigation_finished():
		return
	var target_global_position = self.nav.get_next_path_position()
	var direction = global_position.direction_to(target_global_position)
	var desired_velocity = direction * nav.max_speed
	velocity = desired_velocity * delta
	nav.set_velocity(velocity)


func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			movement_target = get_global_mouse_position()
			nav.target_position = movement_target
