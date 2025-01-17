extends CanvasLayer





@onready var time = 0

@onready var unit :UNIT = get_tree().root.get_child(0).player

func _physics_process(delta: float) -> void:
	$DeathTimerControl/HBoxContainer/DeathTimer.text = str(round(get_tree().root.get_child(0).get_node('PlayerDeathTimer').time_left))
	$Panel/GridContainer/HPBar.max_value = unit.max_hp
	$Panel/GridContainer/HPBar.value = unit.hp
	
	$IconContainer/HBoxContainer/IconHPBar.max_value = unit.max_hp
	$IconContainer/HBoxContainer/IconHPBar.value = unit.hp
	
	$Panel/GridContainer/HPBar/HBoxContainer/HP_label.text = str(round(unit.hp))
	$Panel/GridContainer/HPBar/HBoxContainer/MAX_HP_label.text = str(round(unit.max_hp))
	
	#
	##$Panel/GridContainer/ManaBar/HBoxContainer/MANA_label.text = str(round(unit.MANA))
	##$Panel/GridContainer/ManaBar/HBoxContainer/MAX_MANA_label.text = str(round(unit.MAX_MANA))
	##$Panel/GridContainer/ManaBar.max_value = unit.MAX_MANA
	##$Panel/GridContainer/ManaBar.value = unit.MANA
	$Panel/GridContainer/EXPBar.max_value = unit.experience_for_next_level
	$Panel/GridContainer/EXPBar.value = unit.current_experience
	$Panel/GridContainer/EXPBar/HBoxContainer/EXP_label.text = str(round(unit.current_experience))
	$Panel/GridContainer/EXPBar/HBoxContainer/MAX_EXP_label.text = str(round(unit.experience_for_next_level))
	$Panel/HSplitContainer/LevelContainer/CurrentLevel.text = str(unit.current_level)
	$Panel/HSplitContainer/Attributes/Strength.text = str(unit.strenght)
	##$Panel/HSplitContainer/Attributes/Agility.text = str(unit.agility)
	##$Panel/HSplitContainer/Attributes/Intelligence.text = str(unit.intelligence)
	$Panel/HSplitContainer/Attributes2/Damage.text = str(unit.damage)
	##$Panel/HSplitContainer/Attributes2/Armor.text = str(unit.ARMOR)
	$Panel/HSplitContainer/Attributes2/Speed.text = str(unit.SPEED)


func _on_game_timer_timeout() -> void:
	time += 1
	var minutes = floor(time / 60)
	var seconds = floor(time % 60)
	$TimerContainer/Timer.text = str("%02d:%02d" % [minutes, seconds])


func _on_texture_button_pressed() -> void:
	get_parent().global_position = unit.global_position
