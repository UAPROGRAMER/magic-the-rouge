extends EnemyBrain

class_name GoblinBrain

enum States {
	LOOK,
	CHASE,
}

var state: States = States.LOOK
var way: Array[Vector2i] = []
const VISION_DISTANCE := 10

func look() -> void:
	if is_player_visible(VISION_DISTANCE):
		state = States.CHASE

func chase() -> void:
	if is_player_visible(VISION_DISTANCE):
		way = get_path_to(game.player.coords)
		if way.size() == 2:
			game.player.attack_entity(entity.attack, entity)
		elif way.size() > 2:
			entity.coords = way[1]
			way.remove_at(0)
		else:
			pass
	else:
		if way.size() <= 1:
			state = States.LOOK
		else:
			entity.coords = way[1]
			way.remove_at(0)

func next_turn() -> void:
	match state:
		States.LOOK:
			look()
		States.CHASE:
			chase()
