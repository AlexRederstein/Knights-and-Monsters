extends CharacterBody2D


const SPEED = 2000
@onready var nav:NavigationAgent2D = $NavigationAgent2D
@onready var timer:Timer = $Timer
@onready var player = get_parent().get_node('TestPrayer')
var movement_target = Vector2.ZERO


func _ready():
	nav.max_speed = SPEED
	timer.timeout.connect(update_path)
	#nav.velocity_computed.connect(move_to)

func update_path():
	self.nav.target_position = player.get_global_position()
	
func move_to(velocity):
	move_and_slide()


func _physics_process(delta: float) -> void:
	if self.nav.is_navigation_finished():
		return
	var target_global_position = self.nav.get_next_path_position()
	var direction = global_position.direction_to(target_global_position)
	var safe_velocity = direction * nav.max_speed * delta
	nav.set_velocity(safe_velocity)


func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
	move_and_slide()
