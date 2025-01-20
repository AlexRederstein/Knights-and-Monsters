extends TextureButton
class_name ITEM

@export var item_name = ''
@export var description = ''
@export var price = 0
@export var strenght = 0
@export var intelligence = 0
@export var agility = 0
@onready var world = get_tree().root.get_child(0)
var inshop = true


func _ready():
	#var path = resource_path()
	var label
	if item_name.length() > 0:
		label = Label.new()
		label.text = item_name
		$PanelContainer/VBoxContainer.add_child(label)
	if price != 0:
		label = Label.new()
		label.text = "Стоимость: %s" % [price]
		$PanelContainer/VBoxContainer.add_child(label)
	if strenght != 0:
		label = Label.new()
		label.text = "Сила: +%s" % [strenght]
		$PanelContainer/VBoxContainer.add_child(label)
	if intelligence != 0:
		label = Label.new()
		label.text = "Интеллект: +%s" % [intelligence]
		$PanelContainer/VBoxContainer.add_child(label)
	if agility != 0:
		label = Label.new()
		label.text = "Ловкость: +%s" % [agility]
		$PanelContainer/VBoxContainer.add_child(label)


func _on_mouse_entered() -> void:
	$PanelContainer.visible = true
	$PanelContainer.position.y = -($PanelContainer.size.y + 15)


func _on_mouse_exited() -> void:
	$PanelContainer.visible = false


func _on_pressed() -> void:
	if inshop:
		world.buy_item(self)
	else:
		$SellButton.visible = !$SellButton.visible
		$PanelContainer.visible = false


func _on_sell_button_pressed() -> void:
	world.sell_item(self)
	#queue_free()
