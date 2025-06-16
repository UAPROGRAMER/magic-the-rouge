extends Node

class_name Generator

@onready var game: Game = $".."
@onready var map: Map = $"../Map"
@onready var entities: Node2D = $"../Entities"
@onready var input_handler: InputHandler = $"../InputHandler"

var generator_rng: RandomNumberGenerator = RandomNumberGenerator.new()
var rooms: Array[Room] = []
var start_room: Room
var end_room: Room

func generate() -> void:
	generate_grid_based_map(generator_rng, Vector2i(3, 3), Vector2i(12, 12))
	game.pathfinder.region = Rect2i(0, 0, 36, 36)
	game.pathfinder.update()
	game.update_pathfinder()
	spawn_player()
	spawn_enemies(generator_rng.randi())

func spawn_player() -> void:
	game.player = Entity.new(game, game.player_resource, start_room.center())
	entities.add_child(game.player)
	var camera := Camera2D.new()
	camera.position += Vector2(8, 8)
	game.player.add_child(camera)

func spawn_enemies(seed: int) -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = seed
	rng.state = 0
	var entity_resource: EntityResource = ResourceLoader.load("res://data/entity_resources/goblin.tres")
	for room in rooms:
		var new_enemy := Entity.new(game, entity_resource.duplicate(true), room.center())
		entities.add_child(new_enemy)

class Room:
	var rect: Rect2i
	var room_rng: RandomNumberGenerator
	enum ExitDirection {
		NORTH,
		SOUTH,
		WEST,
		EAST
	}
	
	func _init(rect: Rect2i, seed: int) -> void:
		self.rect = rect
		self.room_rng = RandomNumberGenerator.new()
		self.room_rng.seed = seed
	
	func inside_rect() -> Rect2i:
		return Rect2i(rect.position + Vector2i(1, 1), rect.size - Vector2i(2, 2))
	
	func center() -> Vector2i:
		return rect.position + rect.size / 2
	
	func exit(direction: ExitDirection) -> Vector2i:
		match direction:
			ExitDirection.NORTH:
				return Vector2i(center().x + room_rng.randi_range(-1, 1),
				rect.position.y)
			ExitDirection.SOUTH:
				return Vector2i(center().x + room_rng.randi_range(-1, 1),
				rect.position.y + rect.size.y - 1)
			ExitDirection.WEST:
				return Vector2i(rect.position.x,
				center().y + room_rng.randi_range(-1, 1))
			ExitDirection.EAST:
				return Vector2i(rect.position.x + rect.size.x - 1,
				center().y + room_rng.randi_range(-1, 1))
		return Vector2i.ZERO

func make_room(room: Room) -> void:
	map.make_rect(room.rect, Vector2i(0, 1))
	map.make_filled_rect(room.inside_rect(), Vector2i(1, 0))

func generate_grid_based_map(rng: RandomNumberGenerator, grid_size: Vector2i, ceil_size: Vector2i) -> void:
	map.clear()
	rooms = []
	
	for y in range(grid_size.y):
		for x in range(grid_size.x):
			var room_size := Utility.random_vector(rng, Vector2i(6, 6), ceil_size - Vector2i(3, 3))
			var room_pos := Utility.random_vector(
				rng,
				ceil_size * Vector2i(x, y) + Vector2i(1, 1),
				ceil_size * Vector2i(x + 1, y + 1) - Vector2i(1, 1) - room_size
			)
			var new_room := Room.new(Rect2i(room_pos, room_size), rng.randi())
			rooms.append(new_room)
	
	for room in rooms:
		make_room(room)
	
	for y in range(grid_size.y):
		for x in range(grid_size.x):
			if x + 1 < grid_size.x:
				var from := rooms[x + (y * grid_size.x)].exit(Room.ExitDirection.EAST)
				var to := rooms[x + 1 + (y * grid_size.x)].exit(Room.ExitDirection.WEST)
				map.make_corridor(from, to, true, Vector2i(1, 0))
				map.make_tile(from, Vector2i(0, 2))
				map.make_tile(to, Vector2i(0, 2))
			if y + 1 < grid_size.y:
				var from := rooms[x + (y * grid_size.x)].exit(Room.ExitDirection.SOUTH)
				var to := rooms[x + ((y + 1) * grid_size.x)].exit(Room.ExitDirection.NORTH)
				map.make_corridor(from, to, false, Vector2i(1, 0))
				map.make_tile(from, Vector2i(0, 2))
				map.make_tile(to, Vector2i(0, 2))
	
	var start_room_id: int = rng.randi_range(0, rooms.size() - 1)
	start_room = rooms[start_room_id]
	rooms.remove_at(start_room_id)
	
	var end_room_id: int = rng.randi_range(0, rooms.size() - 1)
	end_room = rooms[end_room_id]
	rooms.remove_at(end_room_id)
	
	map.make_tile(start_room.center(), Vector2i(0, 3))
	map.make_tile(end_room.center(), Vector2i(1, 3))
