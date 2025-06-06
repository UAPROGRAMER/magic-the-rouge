extends Node2D

class_name Game

signal turn_completed()

@onready var generator: Generator = $Generator
@onready var entities: Entities = $Entities
@onready var fov: Fov = $Fov
@onready var map: Map = $Map
@onready var ui: UI = $UI

var game_rng = RandomNumberGenerator.new()

func _ready() -> void:
	game_rng.randomize()
	await get_tree().process_frame
	start()

func start() -> void:
	var map_generation_rng := RandomNumberGenerator.new()
	map_generation_rng.seed = game_rng.randi()
	generator.generate(map_generation_rng)

func end_game() -> void:
	get_tree().quit()

func next_turn() -> void:
	entities.next_turn()
	turn_completed.emit()
