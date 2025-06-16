extends Node2D

class_name Game

signal turn_completed()

@onready var generator: Generator = $Generator
@onready var entities: Entities = $Entities
@onready var fov: Fov = $Fov
@onready var map: Map = $Map
@onready var ui: UI = $UI

var game_rng = RandomNumberGenerator.new()

var player: Entity
var player_resource: EntityResource

var level: int = 1
var level_data: Dictionary[int, LevelData] = {}

var pathfinder: AStarGrid2D = AStarGrid2D.new()

class LevelData:
	var memory: Dictionary[Vector2i, Vector2i]
	var map: Dictionary[Vector2i, Vector2i]
	var entities: Array[EntityResource]
	
	func _init(memory: Dictionary[Vector2i, Vector2i], map: Dictionary[Vector2i, Vector2i],
			   entities: Array[EntityResource]) -> void:
		self.memory = memory
		self.map = map
		self.entities = entities

func _ready() -> void:
	pathfinder.cell_size = Vector2i(16, 16)
	pathfinder.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ALWAYS
	await get_tree().process_frame
	start()

func start() -> void:
	game_rng.seed = OS.get_executable_path().hash() + Time.get_ticks_usec() + Time.get_unix_time_from_system() * pow(PI, PI) * 1000
	generator.generator_rng.seed = get_random_seed()
	player_resource = ResourceLoader.load("res://data/entity_resources/player.tres").duplicate(true)
	make_level()
	$UI/BottomUI/stats/level_label.text = str(level)

func make_level() -> void:
	if player:
		player_resource = player.to_resource()
		player.queue_free()
	entities.clean()
	fov.clean()
	map.clear()
	generator.generate()
	$UI/BottomUI/stats/level_label.text = str(level)

func next_turn() -> void:
	entities.next_turn()
	turn_completed.emit()

func get_random_seed() -> int:
	return game_rng.randi()

func game_over() -> void:
	ui.game_over(player.money + level * 10)

func update_pathfinder() -> void:
	for y in range(pathfinder.size.y):
		for x in range(pathfinder.size.x):
			pathfinder.set_point_solid(Vector2i(x, y), true)
	for cell in map.get_used_cells():
		if map.is_walkable(cell):
			pathfinder.set_point_solid(cell, false)
