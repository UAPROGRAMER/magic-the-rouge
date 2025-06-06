extends Node

class_name InputHandler

var player: Entity

var active: bool = true

func _input(event: InputEvent) -> void:
	if not active:
		return
	if player:
		player.input(event)
