class_name DungeonGenerator
extends Node


const entity_types = {

}


@export_category("Map Dimentions")
@export var map_width: int = 45
@export var map_height: int = 45

@export_category("Dungeon Generation")
@export var number_of_walkers: int = 1
@export var walk_iterations: int = 100
@export var percent_of_floors_goal: float = 0.4

@export_category("Entities RNG")
@export var max_monsters_per_room: int = 2
@export var max_items_per_room: int = 2



var _rng := RandomNumberGenerator.new()

func _ready() -> void:
	_rng.randomize()

func _carve_tile(dungeon: MapData, x: int, y: int) -> void:
	var tile_position = Vector2i(x, y)
	var tile: Tile = dungeon.get_tile(tile_position)
	tile.set_tile_type(dungeon.tile_types.floor)

func generate_dungeon(player: Entity) -> MapData:
	var dungeon := MapData.new(map_width, map_height, player)
	dungeon.entities.append(player)

	var floor_tiles: Array[Vector2i] = []
	var walkers: Array[Vector2i] = []
	
	# Start walker in the center
	var start_pos = Vector2i(map_width / 2, map_height / 2)
	_carve_tile(dungeon, start_pos.x, start_pos.y)
	floor_tiles.append(start_pos)
	
	for _i in number_of_walkers:
		walkers.append(start_pos)
		
	var floors_to_make = int(map_width * map_height * percent_of_floors_goal)
	
	while floor_tiles.size() < floors_to_make:
		for i in range(walkers.size()):
			var walker_pos = walkers[i]
			
			# Move walker
			var direction = Vector2i.ZERO
			while direction == Vector2i.ZERO:
				direction = Vector2i(
					_rng.randi_range(-1, 1),
					_rng.randi_range(-1, 1)
				)
			
			var new_pos = walker_pos + direction
			
			# Clamp to map bounds
			new_pos.x = clamp(new_pos.x, 1, map_width - 2)
			new_pos.y = clamp(new_pos.y, 1, map_height - 2)
			
			walkers[i] = new_pos
			
			var tile = dungeon.get_tile(new_pos)
			if tile.is_walkable() == false: # Check if it's a wall
				_carve_tile(dungeon, new_pos.x, new_pos.y)
				floor_tiles.append(new_pos)
				
			if floor_tiles.size() >= floors_to_make:
				break

	# Place player and entities
	player.grid_position = floor_tiles.pick_random()
	player.map_data = dungeon
	
	_place_all_entities(dungeon, floor_tiles)

	dungeon.setup_pathfinding()
	return dungeon

func _place_all_entities(dungeon: MapData, floor_tiles: Array[Vector2i]):
	for i in range(max_monsters_per_room):
		var pos = floor_tiles.pick_random()
		# Add monster spawning logic here
		pass
		
	for i in range(max_items_per_room):
		var pos = floor_tiles.pick_random()
		# Add item spawning logic here
		pass

func _place_entities(dungeon: MapData, room: Rect2i) -> void:
	pass
