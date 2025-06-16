extends CharacterBrain

class_name PlayerBrain

var regeneration_timer: int = 0

func ready() -> void:
	game.fov.update_fov(entity.coords)
	update_info()

func interact(delta: Vector2i) -> void:
	var other := game.entities.get_entity_at(entity.coords + delta)
	if delta == Vector2i.ZERO:
		pass
	elif other != null:
		other.attack_entity(entity.attack, entity)
	elif game.map.get_cell_atlas_coords(entity.coords + delta) == Vector2i(0, 2):
		game.map.make_tile(entity.coords + delta, Vector2i(1, 2))
		game.update_pathfinder()
	elif game.map.get_cell_atlas_coords(entity.coords + delta) == Vector2i(1, 3):
		game.level += 1
		game.make_level()
	else:
		move(delta)
	game.next_turn()
	game.fov.update_fov(entity.coords)

func input(event: InputEvent) -> void:
	if event.is_action_pressed("DownLeft"):
		interact(Vector2i(-1, 1))
	elif event.is_action_pressed("Down"):
		interact(Vector2i(0, 1))
	elif event.is_action_pressed("DownRight"):
		interact(Vector2i(1, 1))
	elif event.is_action_pressed("Left"):
		interact(Vector2i(-1, 0))
	elif event.is_action_pressed("Center"):
		interact(Vector2i(0, 0))
	elif event.is_action_pressed("Right"):
		interact(Vector2i(1, 0))
	elif event.is_action_pressed("UpLeft"):
		interact(Vector2i(-1, -1))
	elif event.is_action_pressed("Up"):
		interact(Vector2i(0, -1))
	elif event.is_action_pressed("UpRight"):
		interact(Vector2i(1, -1))

func update_info() -> void:
	game.ui.update_info(entity.max_health, entity.health, entity.money)

func next_turn() -> void:
	if entity.health < entity.max_health:
		if regeneration_timer == 0:
			regeneration_timer = 5
		else:
			regeneration_timer -= 1
		if regeneration_timer == 1:
			entity.health += 1

func on_turn_completed() -> void:
	update_info()

func on_health_below_zero() -> void:
	game.game_over()
