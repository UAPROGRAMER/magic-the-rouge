extends Node

class_name Utility

const TILE_SIZE := 16

static func random_vector(rng: RandomNumberGenerator, from: Vector2i, to: Vector2i) -> Vector2i:
	return Vector2i(rng.randi_range(from.x, to.x), rng.randi_range(from.y, to.y))

static func coords_to_pos(coords: Vector2i) -> Vector2:
	return Vector2(coords * TILE_SIZE)

static func pos_to_coords(pos: Vector2) -> Vector2i:
	return Vector2i(pos / TILE_SIZE) - Vector2i(int(pos.x < 0), int(pos.y < 0))
