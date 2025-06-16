extends CharacterBrain

class_name EnemyBrain

func is_player_visible(vision_distance: int) -> bool:
	if (entity.coords - game.player.coords).length() > vision_distance:
		return false
	
	var start := entity.coords
	var end := game.player.coords
	
	var dx := end.x - start.x
	var dy := end.y - start.y
	if dx != 0:
		var y := start.y
		var p := 2 * dy - dx
		for i in range(dx + 1):
			if not game.map.is_walkable(Vector2i(start.x + i, y)):
				return false
			
			if p >= 0:
				y += 1
				p += 2 * dy - 2 * dx
			else:
				p += 2 * dy
	
	return true

func get_path_to(coords: Vector2i) -> Array[Vector2i]:
	return game.pathfinder.get_id_path(entity.coords, coords)
