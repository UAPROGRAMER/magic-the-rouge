extends Node2D

class_name Entities

func is_empty(coords: Vector2i) -> bool:
	for child: Entity in get_children():
		if child.coords == coords:
			return false
	return true

func get_entity_at(coords: Vector2i) -> Entity:
	for child: Entity in get_children():
		if child.coords == coords:
			return child
	return null

func next_turn() -> void:
	for child: Entity in get_children():
		child.next_turn()

func clean() -> void:
	for child in get_children():
		child.queue_free()

func get_entities() -> Array[EntityResource]:
	var entities: Array[EntityResource] = []
	for child: Entity in get_children():
		entities.push_back(child.to_resource())
	return entities
