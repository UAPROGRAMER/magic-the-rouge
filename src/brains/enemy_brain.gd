extends CharacterBrain

class_name EnemyBrain

func is_player_visible(vision_distance: int) -> bool:
	if game.player.coords.length() > vision_distance:
		return false
	return true
