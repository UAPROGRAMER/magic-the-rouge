extends TileMapLayer

class_name Map

# CUSTOM DATA STUFF

func get_ceil_tile_custom_data(coords: Vector2i, layer_name: String) -> Variant:
	var tile_data := get_cell_tile_data(coords)
	return tile_data.get_custom_data(layer_name) if tile_data else null

func is_walkable(coords: Vector2i) -> bool:
	var tile_data = get_ceil_tile_custom_data(coords, "walkable")
	return true if tile_data else false

func is_seethrough(coords: Vector2i) -> bool:
	var tile_data = get_ceil_tile_custom_data(coords, "seethrough")
	return tile_data if tile_data else false

# GENERATION

func make_tile(coords: Vector2i, atlas_coords: Vector2i) -> void:
	set_cell(coords, 0, atlas_coords)

func make_rect(rect: Rect2i, atlas_coords: Vector2i) -> void:
	for x in range(rect.position.x, rect.position.x + rect.size.x):
		make_tile(Vector2i(x, rect.position.y), atlas_coords)
	for x in range(rect.position.x, rect.position.x + rect.size.x):
		make_tile(Vector2i(x, rect.position.y + rect.size.y - 1), atlas_coords)
	for y in range(rect.position.y + 1, rect.position.y + rect.size.y - 1):
		make_tile(Vector2i(rect.position.x, y), atlas_coords)
	for y in range(rect.position.y + 1, rect.position.y + rect.size.y - 1):
		make_tile(Vector2i(rect.position.x + rect.size.x - 1, y), atlas_coords)

func make_filled_rect(rect: Rect2i, atlas_coords: Vector2i) -> void:
	for y in range(rect.size.y):
		for x in range(rect.size.x):
			make_tile(rect.position + Vector2i(x, y), atlas_coords)

func make_corridor(from: Vector2i, to: Vector2i, horrizontal: bool, atlas_coords: Vector2i) -> void:
	var middle := (from + to) / 2
	if horrizontal:
		for x in range(min(from.x, middle.x), max(from.x, middle.x) + 1):
			make_tile(Vector2i(x, from.y), atlas_coords)
		for y in range(min(from.y, to.y), max(from.y, to.y) + 1):
			make_tile(Vector2i(middle.x, y), atlas_coords)
		for x in range(min(middle.x, to.x), max(middle.x, to.x) + 1):
			make_tile(Vector2i(x, to.y), atlas_coords)
	else:
		for y in range(min(from.y, middle.y), max(from.y, middle.y) + 1):
			make_tile(Vector2i(from.x, y), atlas_coords)
		for x in range(min(from.x, to.x), max(from.x, to.x) + 1):
			make_tile(Vector2i(x, middle.y), atlas_coords)
		for y in range(min(middle.y, to.y), max(middle.y, to.y) + 1):
			make_tile(Vector2i(to.x, y), atlas_coords)
