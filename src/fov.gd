extends TileMapLayer

class_name Fov

@onready var map: Map = $"../Map"

# dont touch this shi for now, it (and i) WILL break

var player_position: Vector2i
const MAX_VISION_DISTANCE: int = 12

var memory: Dictionary[Vector2i, Vector2i] = {}

func clean() -> void:
	memory = {}
	clear()

func update_fov(coords: Vector2i) -> void:
	clear_fov(coords)
	for key: Vector2i in memory.keys():
		set_cell(key, 0, memory[key])
	player_position = coords
	shadow_casting(coords)

func clear_fov(coords: Vector2i) -> void:
	for y in range(17):
		for x in range(31):
			set_cell(coords - Vector2i(15, 8) + Vector2i(x, y), 0, Vector2i.ZERO)

func pos_to_coords(pos: Vector2) -> Vector2i:
	return local_to_map(pos)

func shadow_casting(origin : Vector2):
	mark_visible(origin)
	for i in range(4):
		var quadrant = Quadrant.new(i, origin)
		var first_row = Row.new(1, -1, 1)
		scan(first_row, quadrant)

func reveal(tile: Vector2i, quadrant: Quadrant):
	var result = quadrant.transform(tile)
	mark_visible(result)

func mark_visible(tile: Vector2i):
	if distance(player_position, tile) > MAX_VISION_DISTANCE: return
	erase_cell(tile)
	memory[tile] = map.get_cell_atlas_coords(tile)

# Checks if a tile is considered a wall in the given quadrant.
func is_wall(tile, quadrant : Quadrant) -> bool:
	if not tile: return false
	var result = quadrant.transform(tile)
	return is_blocking(result)

# Determines if a tile is considered a floor in the given quadrant.
func is_floor(tile, quadrant : Quadrant) -> bool:
	if not tile: return false
	var result = quadrant.transform(tile)
	return not is_blocking(result)

# Determines if a tile is blocking the vision (e.g. a wall).
func is_blocking(tile : Vector2) -> bool:
	return not map.is_seethrough(tile)

# Calculates the slope between the origin and a given tile, used to determine vision angles.
func slope(tile : Vector2) -> float:
	var row_depth = tile.x
	var col = tile.y
	return (2.0 * col - 1.0) / (2.0 * row_depth)

# Determines if a tile falls symmetrically within the range of a given row for shadow casting.
func is_symmetric(row : Row, tile : Vector2) -> bool:
	var col = tile.y
	return col >= row.depth * row.start_slope and col <= row.depth * row.end_slope

# Scans tiles in a given row and quadrant to determine their visibility.
func scan(row : Row, quadrant : Quadrant):
	if row.depth > MAX_VISION_DISTANCE:
		return
	var prev_tile = null
	for tile in row.tiles():
		if is_wall(tile, quadrant) or is_symmetric(row, tile):
			reveal(tile, quadrant)
		if is_wall(prev_tile, quadrant) and is_floor(tile, quadrant):
			row.start_slope = slope(tile)
		if is_floor(prev_tile, quadrant) and is_wall(tile, quadrant):
			var next_row = row.next()
			next_row.end_slope = slope(tile)
			scan(next_row, quadrant)
		prev_tile = tile
	if is_floor(prev_tile, quadrant):
		scan(row.next(), quadrant)

# Represents one of the 4 relative quadrants around the player.
class Quadrant:
	var cardinal
	var ox
	var oy

	func _init(cardinal, origin):
		self.cardinal = cardinal
		self.ox = origin.x
		self.oy = origin.y

	# Transforms a tile's position based on its quadrant.
	func transform(tile : Vector2):
		var row = tile.x
		var col = tile.y
		match self.cardinal:
			0:
				return Vector2(self.ox + col, self.oy - row)
			1:
				return Vector2(self.ox + row, self.oy + col)
			2:
				return Vector2(self.ox + col, self.oy + row)
			3:
				return Vector2(self.ox - row, self.oy + col)

# Represents a row of tiles to be scanned during shadow casting.
class Row:
	var depth
	var start_slope
	var end_slope

	func _init(depth : int, start_slope, end_slope):
		self.depth = depth
		self.start_slope = start_slope
		self.end_slope = end_slope

	# Returns the tiles within the row that need to be scanned.
	func tiles() -> Array:
		var min_col = round_ties_up(self.depth * self.start_slope)
		var max_col = round_ties_down(self.depth * self.end_slope)
		var result = []
		for i in range(min_col, min(max_col + 1, MAX_VISION_DISTANCE)):
			result.append(Vector2(self.depth, i))
		return result

	# Gets the next row in sequence for the shadow casting process.
	func next() -> Row:
		return Row.new(self.depth + 1, self.start_slope, self.end_slope)

	# Utility functions for rounding numbers.
	func round_ties_up(n) -> float:
		return floor(n + 0.5)

	func round_ties_down(n) -> float:
		return ceil(n - 0.5)

# Utility: Get distance between two points.
func distance(a: Vector2, b: Vector2) -> float:
	return a.distance_to(b)
