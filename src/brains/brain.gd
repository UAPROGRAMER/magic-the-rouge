extends Resource

class_name Brain

var entity: Entity
var game: Game

func setup(game: Game, entity: Entity) -> void:
	self.game = game
	self.entity = entity

func ready() -> void:
	pass

func input(event: InputEvent) -> void:
	pass

func next_turn() -> void:
	pass
