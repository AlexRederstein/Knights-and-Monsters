extends SPELL

func action(target = null):
	player.invicible = true

func spell_is_over():
	player.invicible = false
	
