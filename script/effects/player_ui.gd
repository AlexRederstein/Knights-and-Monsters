extends CanvasLayer

@onready var unit :UNIT = get_parent().player

func _ready():
	$DeathTimerControl.visible = false
	$ShopContainer.visible = false

func _physics_process(delta: float) -> void:
	
	$DeathTimerControl/HBoxContainer/DeathTimer.text = str(round(get_parent().world.get_node('PlayerDeathTimer').time_left))
#	Золото
	$InventoryContainer/VBoxContainer/HBoxContainer/GoldLabel.text = str(unit.current_gold)
	
#	Шкала здоровья
	$Panel/GridContainer/HPBar.max_value = unit.max_hp
	$Panel/GridContainer/HPBar.value = unit.hp
	$Panel/GridContainer/HPBar/HPIncrementLabel.text = '+'+str(snapped(unit.hp_recovery, 0.01))
	
	$Panel/GridContainer/HPBar/HBoxContainer/HP_label.text = str(round(unit.hp))
	$Panel/GridContainer/HPBar/HBoxContainer/MAX_HP_label.text = str(round(unit.max_hp))
#	Шкала здоровья на иконке героя
	$IconContainer/HBoxContainer/IconHPBar.max_value = unit.max_hp
	$IconContainer/HBoxContainer/IconHPBar.value = unit.hp
	
#	Шкала маны
	$Panel/GridContainer/ManaBar/HBoxContainer/MANA_label.text = str(round(unit.mana))
	$Panel/GridContainer/ManaBar/HBoxContainer/MAX_MANA_label.text = str(round(unit.max_mana))
	$Panel/GridContainer/ManaBar/ManaIncrementLabel.text = '+'+str(snapped(unit.mana_recovery, 0.01))
	
	$Panel/GridContainer/ManaBar.max_value = unit.max_mana
	$Panel/GridContainer/ManaBar.value = unit.mana
	
#	Шкала маны на иконке героя

	$IconContainer/HBoxContainer/IconManaBar.max_value = unit.max_mana
	$IconContainer/HBoxContainer/IconManaBar.value = unit.mana
#	Шкала опыта
	$Panel/GridContainer/EXPBar.max_value = unit.experience_for_next_level
	$Panel/GridContainer/EXPBar.value = unit.current_experience
	$Panel/GridContainer/EXPBar/HBoxContainer/EXP_label.text = str(round(unit.current_experience))
	$Panel/GridContainer/EXPBar/HBoxContainer/MAX_EXP_label.text = str(round(unit.experience_for_next_level))
#	Уровень
	$Panel/HSplitContainer/LevelContainer/CurrentLevel.text = str(unit.current_level)
#	Статы
	$Panel/HSplitContainer/Attributes/Strength.text = str(unit.strenght)
	$Panel/HSplitContainer/Attributes/Agility.text = str(unit.agility)
	$Panel/HSplitContainer/Attributes/Intelligence.text = str(unit.intelligence)
	$Panel/HSplitContainer/Attributes2/Damage.text = str(unit.damage)
	$Panel/HSplitContainer/Attributes2/Armor.text = str(unit.armor)
	$Panel/HSplitContainer/Attributes2/Speed.text = str(unit.SPEED)



func _on_texture_button_pressed() -> void:
	get_parent().global_position = unit.global_position
