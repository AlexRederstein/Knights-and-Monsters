extends SPELL

func action(target = null):
	if target.hp < target.max_hp:
		target.hp += 100
		return true
	return false
