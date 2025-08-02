class_name DungeonGenerator
extends Node

const entity_types = {
	# Add your entity types here
}

@export_category("Map Dimentions")
@export var map_width: int = 90
@export var map_height: int = 90

@export_category("Dungeon Generation")
@export var walk_iterations: int = 500

@export_category("Entities RNG")
@export var max_monsters_per_room: int = 2
@export var max_items_per_room: int = 2

var _rng := RandomNumberGenerator.new()

func _ready() -> void:
	_rng.randomize()

func _carve_tile(dungeon: MapData, x: int, y: int) -> void:
	var tile_position = Vector2i(x, y)
	var tile: Tile = dungeon.get_tile(tile_position)
	if tile:
		tile.set_tile_type(dungeon.tile_types.floor)

func generate_dungeon(player: Entity) -> MapData:
	var dungeon := MapData.new(map_width, map_height, player)
	dungeon.entities.append(player)

	var walker = Walker.new(Vector2(map_width / 2, map_height / 2), Rect2(1, 1, map_width - 2, map_height - 2), _rng)
	var floor_tiles_vector2 = walker.walk(walk_iterations)
	
	var floor_tiles: Array[Vector2i] = []
	for pos in floor_tiles_vector2:
		var pos_int = Vector2i(pos)
		if not floor_tiles.has(pos_int):
			floor_tiles.append(pos_int)

	for tile_pos in floor_tiles:
		_carve_tile(dungeon, tile_pos.x, tile_pos.y)

	# Place player and entities
	if not floor_tiles.is_empty():
		player.grid_position = floor_tiles.pick_random()
	else:
		# Fallback if no floor tiles were generated
		player.grid_position = Vector2i(map_width / 2, map_height / 2)
		_carve_tile(dungeon, player.grid_position.x, player.grid_position.y)
		floor_tiles.append(player.grid_position)
		
	player.map_data = dungeon
	
	# The new walker creates rooms, we can use them to place entities.
	_place_all_entities(dungeon, walker.rooms)

	dungeon.setup_pathfinding()
	return dungeon

func _place_all_entities(dungeon: MapData, rooms: Array):
	for room in rooms:
		var room_rect = Rect2i(room.position, room.size)
		_place_entities(dungeon, room_rect)


func _place_entities(dungeon: MapData, room: Rect2i) -> void:
	# This is just an example of how you could place monsters and items in rooms
	# You will need to have your entity scenes defined in the `entity_types` dictionary
	
	# Place Monsters
	var monster_count = _rng.randi_range(0, max_monsters_per_room)
	for _i in monster_count:
		var pos = Vector2i(
			_rng.randi_range(room.position.x, room.position.x + room.size.x - 1),
			_rng.randi_range(room.position.y, room.position.y + room.size.y - 1)
		)
		# Add monster spawning logic here, e.g.:
		# var monster_type = entity_types.values().pick_random()
		# var monster = monster_type.instantiate()
		# monster.grid_position = pos
		# dungeon.entities.append(monster)
		pass

	# Place Items
	var item_count = _rng.randi_range(0, max_items_per_room)
	for _i in item_count:
		var pos = Vector2i(
			_rng.randi_range(room.position.x, room.position.x + room.size.x - 1),
			_rng.randi_range(room.position.y, room.position.y + room.size.y - 1)
		)
		# Add item spawning logic here
		pass

# The new Walker class
class Walker:
	const DIRECTIONS = [Vector2.RIGHT, Vector2.UP, Vector2.LEFT, Vector2.DOWN]

	var position = Vector2.ZERO
	var direction = Vector2.RIGHT
	var borders = Rect2()
	var step_history = []
	var steps_since_turn = 6
	var rooms = []
	var _rng: RandomNumberGenerator

	func _init(starting_position, new_borders, rng):
		assert(new_borders.has_point(starting_position))
		position = starting_position
		step_history.append(position)
		borders = new_borders
		_rng = rng

	func walk(steps):
		place_room(position)
		for _i in range(steps):
			if steps_since_turn >= 12:
				change_direction()
			
			if step():
				step_history.append(position)
			else:
				change_direction()
		return step_history

	func step():
		var target_position = position + direction
		if borders.has_point(target_position):
			steps_since_turn += 1
			position = target_position
			return true
		else:
			return false

	func change_direction():
		place_room(position)
		steps_since_turn = 0
		var directions = DIRECTIONS.duplicate()
		directions.erase(direction)
		directions.shuffle()
		direction = directions.pop_front()
		while not borders.has_point(position + direction):
			if directions.is_empty():
				# Failsafe if stuck
				direction = DIRECTIONS.pick_random()
				break
			direction = directions.pop_front()

	func create_room(pos, s):
		return {"position": pos, "size": s}

	func place_room(pos):
		var size = Vector2(_rng.randi_range(4, 10), _rng.randi_range(4, 10))
		var top_left_corner = (pos - size/2).ceil()
		rooms.append(create_room(top_left_corner, size))
		for y in range(size.y):
			for x in range(size.x):
				var new_step = top_left_corner + Vector2(x, y)
				if borders.has_point(new_step):
					step_history.append(new_step)

	func get_end_room():
		if rooms.is_empty():
			return null
		var end_room = rooms.front()
		var starting_position = step_history.front()
		for room in rooms:
			if starting_position.distance_to(room.position) > starting_position.distance_to(end_room.position):
				end_room = room
		return end_room
