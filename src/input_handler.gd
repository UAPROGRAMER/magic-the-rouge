extends Node

class_name InputHandler

@onready var game: Game = $".."

var active: bool = true

func get_player() -> Entity:
	return game.player

func _input(event: InputEvent) -> void:
	if not active:
		return
	elif get_player():
		get_player().input(event)
