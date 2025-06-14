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
	#game_rng.randomize()
	game_rng.seed = 0
	game_rng.state = 0
	await get_tree().process_frame
	start()

func start() -> void:
	player_resource = ResourceLoader.load("res://data/entity_resources/player.tres").duplicate(true)
	generator.generate()

func make_level() -> void:
	player_resource = player.to_resource()
	player.queue_free()
	entities.clean()
	fov.clean()
	map.clear()
	generator.generate()

func end_game() -> void:
	get_tree().quit()

func next_turn() -> void:
	entities.next_turn()
	turn_completed.emit()

func get_random_seed() -> int:
	return game_rng.randi()
