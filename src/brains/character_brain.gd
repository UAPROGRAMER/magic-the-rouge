extends Brain

class_name CharacterBrain

func setup(game: Game, entity: Entity) -> void:
	super.setup(game, entity)
	entity.connect("health_below_zero", on_health_below_zero)
	entity.connect("attacked", on_attacked)
	game.connect("turn_completed", on_turn_completed)

func on_health_below_zero() -> void:
	entity.queue_free()

func on_attacked(attack: int, attaker: Entity) -> void:
	entity.run_attack_particles()

func on_turn_completed() -> void:
	pass

func move(delta: Vector2i) -> void:
	if not game.map.is_walkable(entity.coords + delta) or \
		not game.entities.is_empty(entity.coords + delta):
		return
	entity.coords += delta
