extends TextureButton
class_name SPELL


@export var spell_name = "Стандартное название"
@export var description = "Стандартное описание"

@export var isactive = true
@export var isdirected = true
@export var spell_target_allies = true
@export var spell_target_enemies = false

@export var duration = 0
@export var cooldown = 5
@export var mana_cost :int = 100
@export var spell_level :int = 0

@onready var player = get_tree().root.get_child(0).camera.player
@onready var camera = get_tree().root.get_child(0).camera
@onready var spell_timer = $SpellTimer
@onready var timer = $CoolDownTimer
@onready var cool_down_label = $Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var label = Label.new()
	label.text = "%s\nМана: %s\n%s" % [spell_name, mana_cost ,description]
	$PanelContainer/VBoxContainer.add_child(label)
	
	spell_timer.wait_time = duration
	spell_timer.timeout.connect(spell_is_over)
	timer.wait_time = cooldown
	cool_down_label.visible = false

func start_cooldown():
	camera.place_tip_on_ui('')
	player.mana -= mana_cost
	disabled = true
	cool_down_label.visible = true
	timer.start()
	
func _on_timer_timeout() -> void:
	cool_down_label.visible = false
	disabled = false

func spell_is_over():
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	cool_down_label.text = str(snapped(timer.time_left, 0.1))

func _on_mouse_entered() -> void:
	$PanelContainer.visible = true
	$PanelContainer.position.y = -($PanelContainer.size.y + 15)

func _on_mouse_exited() -> void:
	$PanelContainer.visible = false


func _on_pressed() -> void:
	if !isactive:
		return
	if player.mana > mana_cost:
		if isdirected:
			camera.place_tip_on_ui('Укажите дружественного юнита', 0)
			camera.current_spell = self
		else:
			action()
			spell_timer.start()
			start_cooldown()
	else:
		camera.place_tip_on_ui('Нет маны')
	
func action(target = null):
	pass
