extends Sprite2D

class_name Entity

signal health_below_zero()
signal attacked(attack: int, attacker: Entity)

var brain: Brain
var max_health: int
var health: int

var attack_particles: AttackParticles

var coords: Vector2i:
	set(new_coords):
		coords = new_coords
		position = Utility.coords_to_pos(coords)

func _ready() -> void:
	brain.ready()

func _init(game: Game, entity_resource: EntityResource, coords: Vector2i) -> void:
	centered = false
	texture = entity_resource.texture
	self.coords = coords
	max_health = entity_resource.max_health
	health = max_health
	
	material = ResourceLoader.load("res://data/materials/entity_shader_material.tres").duplicate(true)
	
	brain = entity_resource.brain
	brain.setup(game, self)
	
	attack_particles = load("res://src/particles/attack_particles.tscn").instantiate()
	
	add_child(attack_particles)

func input(event: InputEvent) -> void:
	brain.input(event)

func next_turn() -> void:
	brain.next_turn()

func attack(attack: int, attacker: Entity) -> void:
	health -= attack
	attacked.emit(attack, attacker)
	if health <= 0:
		health_below_zero.emit()

func set_color_modifier(color: Vector4) -> void:
	material.set_shader_parameter("color_modifier", color)

func run_attack_particles() -> void:
	attack_particles.activate()
