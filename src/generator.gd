extends Node

class_name Generator

@onready var game: Game = $".."
@onready var map: Map = $"../Map"
@onready var entities: Node2D = $"../Entities"
@onready var input_handler: InputHandler = $"../InputHandler"

func generate(rng: RandomNumberGenerator) -> void:
	generate_grid_based_map(rng, Vector2i(3, 3), Vector2i(12, 12))

class Room:
	var rect: Rect2i
	var rng_value: float
	enum ExitDirection {
		NORTH,
		SOUTH,
		WEST,
		EAST
	}
	
	func _init(rect: Rect2i, rng: RandomNumberGenerator) -> void:
		self.rect = rect
		self.rng_value = rng.randf_range(-1.0, 1.0)
	
	func inside_rect() -> Rect2i:
		return Rect2i(rect.position + Vector2i(1, 1), rect.size - Vector2i(2, 2))
	
	func center() -> Vector2i:
		return rect.position + rect.size / 2
	
	func rng_value_y() -> float:
		return -1 if rng_value < 0 else 1 * (1 - abs(rng_value))
	
	func exit(direction: ExitDirection) -> Vector2i:
		match direction:
			ExitDirection.NORTH:
				return Vector2i(center().x + round(rng_value), rect.position.y)
			ExitDirection.SOUTH:
				return Vector2i(center().x - round(rng_value), rect.position.y + rect.size.y - 1)
			ExitDirection.WEST:
				return Vector2i(rect.position.x, center().y + round(rng_value_y()))
			ExitDirection.EAST:
				return Vector2i(rect.position.x + rect.size.x - 1, center().y - round(rng_value_y()))
		return Vector2i.ZERO

func make_room(room: Room) -> void:
	map.make_rect(room.rect, Vector2i(0, 1))
	map.make_filled_rect(room.inside_rect(), Vector2i(1, 0))

func generate_grid_based_map(rng: RandomNumberGenerator, grid_size: Vector2i, ceil_size: Vector2i) -> void:
	map.clear()
	
	var rooms: Array[Room] = []
	for y in range(grid_size.y):
		for x in range(grid_size.x):
			var room_size := Utility.random_vector(rng, Vector2i(6, 6), ceil_size - Vector2i(3, 3))
			var room_pos := Utility.random_vector(
				rng,
				ceil_size * Vector2i(x, y) + Vector2i(1, 1),
				ceil_size * Vector2i(x + 1, y + 1) - Vector2i(1, 1) - room_size
			)
			var new_room := Room.new(Rect2i(room_pos, room_size), rng)
			rooms.append(new_room)
	
	for room in rooms:
		make_room(room)
	
	for y in range(grid_size.y):
		for x in range(grid_size.x):
			if x + 1 < grid_size.x:
				var from := rooms[x + (y * grid_size.x)].exit(Room.ExitDirection.EAST)
				var to := rooms[x + 1 + (y * grid_size.x)].exit(Room.ExitDirection.WEST)
				map.make_corridor(from, to, true, Vector2i(1, 0))
				map.make_tile(from, Vector2i(1, 2))
				map.make_tile(to, Vector2i(1, 2))
			if y + 1 < grid_size.y:
				var from := rooms[x + (y * grid_size.x)].exit(Room.ExitDirection.SOUTH)
				var to := rooms[x + ((y + 1) * grid_size.x)].exit(Room.ExitDirection.NORTH)
				map.make_corridor(from, to, false, Vector2i(1, 0))
				map.make_tile(from, Vector2i(1, 2))
				map.make_tile(to, Vector2i(1, 2))
	
	var start_room_id: int = rng.randi_range(0, rooms.size() - 1)
	var start_room: Room = rooms[start_room_id]
	rooms.remove_at(start_room_id)
	
	var player_resource: EntityResource = ResourceLoader.load("res://data/entity_resources/human.tres").duplicate(true)
	player_resource.brain = PlayerBrain.new()
	var player: Entity = Entity.new(
		game,
		player_resource,
		start_room.center()
	)
	entities.add_child(player)
	
	var camera := Camera2D.new()
	camera.offset = Vector2(8, 8)
	player.add_child(camera)
	
	input_handler.player = player
	
	var human_room_id: int = rng.randi_range(0, rooms.size() - 1)
	var human_room: Room = rooms[human_room_id]
	
	var human_resource: EntityResource = ResourceLoader.load("res://data/entity_resources/human.tres").duplicate(true)
	var human: Entity = Entity.new(
		game,
		human_resource,
		human_room.center()
	)
	entities.add_child(human)
