extends Brain

class_name CharacterBrain

var game_setup := false

func setup(game: Game, entity: Entity) -> void:
	super.setup(game, entity)
	entity.connect("health_below_zero", on_health_below_zero)
	entity.connect("attacked", on_attacked)
	if not game_setup:
		game.connect("turn_completed", on_turn_completed)
		game_setup = true

func on_health_below_zero() -> void:
	entity.queue_free()

func on_attacked(attack: int, attacker: Entity) -> void:
	if entity.health <= 0 and attacker:
		attacker.money += entity.money
	entity.run_attack_particles()

func on_turn_completed() -> void:
	pass

func move(delta: Vector2i) -> void:
	if not game.map.is_walkable(entity.coords + delta) or \
		not game.entities.is_empty(entity.coords + delta):
		return
	entity.coords += delta
