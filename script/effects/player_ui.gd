extends CanvasLayer

@onready var unit = self.get_parent()

func _physics_process(delta: float) -> void:
	$Panel/GridContainer/HPBar.max_value = unit.MAX_HP
	$Panel/GridContainer/HPBar.value = unit.HP
	$Panel/GridContainer/HPBar/HBoxContainer/HP_label.text = str(round(unit.HP))
	$Panel/GridContainer/HPBar/HBoxContainer/MAX_HP_label.text = str(round(unit.MAX_HP))
	
	#$Panel/GridContainer/ManaBar/HBoxContainer/MANA_label.text = str(round(unit.MANA))
	#$Panel/GridContainer/ManaBar/HBoxContainer/MAX_MANA_label.text = str(round(unit.MAX_MANA))
	#$Panel/GridContainer/ManaBar.max_value = unit.MAX_MANA
	#$Panel/GridContainer/ManaBar.value = unit.MANA
	$Panel/GridContainer/EXPBar.max_value = unit.experience_for_next_level
	$Panel/GridContainer/EXPBar.value = unit.current_experience
	$Panel/GridContainer/EXPBar/HBoxContainer/EXP_label.text = str(round(unit.current_experience))
	$Panel/GridContainer/EXPBar/HBoxContainer/MAX_EXP_label.text = str(round(unit.experience_for_next_level))
	$Panel/HSplitContainer/LevelContainer/CurrentLevel.text = str(unit.current_level)
	
	$Panel/HSplitContainer/Attributes/Strength.text = str(unit.strenght)
	$Panel/HSplitContainer/Attributes/Agility.text = str(unit.agility)
	$Panel/HSplitContainer/Attributes/Intelligence.text = str(unit.intelligence)
	$Panel/HSplitContainer/Attributes2/Damage.text = str(unit.damage)
	$Panel/HSplitContainer/Attributes2/Armor.text = str(unit.ARMOR)
	$Panel/HSplitContainer/Attributes2/Speed.text = str(unit.SPEED)
