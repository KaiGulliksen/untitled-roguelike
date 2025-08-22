class_name Hub
extends Node2D

@export var fov_radius: int = 30
@export var hub_width: int = 74  # Based on your tilemap data
@export var hub_height: int = 74
@export var player_spawn_position: Vector2i = Vector2i(35, 20)  # Center of hub

var map_data: MapData

@onready var tile_map_layer: TileMapLayer = $TileMapLayer
@onready var entities: Node2D = $Entities
@onready var map: Node2D = $"../Map"
@onready var field_of_view: FieldOfView = $FieldOfView if has_node("FieldOfView") else preload("res://Map/field_of_view.gd").new()

func _ready() -> void:
	SignalBus.enter_portal.connect(enter_portal)
	# Add FieldOfView node if it doesn't exist
	if not has_node("FieldOfView"):
		field_of_view = preload("res://Map/field_of_view.gd").new()
		field_of_view.name = "FieldOfView"
		add_child(field_of_view)
	
	# Add Entities node if it doesn't exist
	if not has_node("Entities"):
		entities = Node2D.new()
		entities.name = "Entities"
		add_child(entities)

func new(player: Entity) -> void:
	# Create map data for the hub
	map_data = MapData.new(hub_width, hub_height, player)
	
	# Read the handcrafted tilemap and populate map_data
	_load_tiles_from_tilemap()
	
	# Place player at spawn position
	player.grid_position = player_spawn_position
	player.map_data = map_data
	
	# Add player to entities
	map_data.entities.append(player)
	
	# Setup pathfinding for the hub
	map_data.setup_pathfinding()
	
	# Connect signals if needed
	if map_data.has_signal("entity_placed"):
		map_data.entity_placed.connect(_on_entity_placed)
	
	# Place entities
	_place_entities()
	
	# Initial FOV update
	update_fov(player.grid_position)
	


func _load_tiles_from_tilemap() -> void:
	# Read the existing tilemap and create Tile objects in map_data
	for y in range(hub_height):
		for x in range(hub_width):
			var tile_position = Vector2i(x, y)
			var tile_data = tile_map_layer.get_cell_tile_data(tile_position)
			
			# Get the tile from map_data (it's already created as walls by default)
			var tile = map_data.get_tile(tile_position)
			if not tile:
				continue
			
			if tile_data != null:
				# Check for custom data first
				var tile_type = tile_data.get_custom_data("tile_type")
				var is_walkable = tile_data.get_custom_data("is_walkable")
				var is_portal = tile_data.get_custom_data("is_portal")
				
				if is_portal:
					tile.set_tile_type(map_data.tile_types.portal)
				elif tile_type == "floor" or is_walkable == true:
					tile.set_tile_type(map_data.tile_types.floor)
				else:
					# Fallback: assume walls for placed tiles
					tile.set_tile_type(map_data.tile_types.wall)
			else:
				# No tile placed = wall
				tile.set_tile_type(map_data.tile_types.wall)

func _place_entities() -> void:
	for entity in map_data.entities:
		entities.add_child(entity)

func _on_entity_placed(entity: Entity) -> void:
	entities.add_child(entity)

func update_fov(player_position: Vector2i) -> void:
	# Add safety check for map_data
	if not map_data:
		push_error("update_fov called before map_data is initialized")
		return
		
	field_of_view.update_fov(map_data, player_position, fov_radius)
	
	# Update entity visibility with null checks
	for entity in map_data.entities:
		if not entity:
			continue
			
		var tile = map_data.get_tile(entity.grid_position)
		if tile:
			entity.visible = tile.is_in_view
		else:
			# Entity is out of bounds or on invalid tile
			entity.visible = false
			push_warning("Entity at invalid position: " + str(entity.grid_position))

func add_entity(entity: Entity) -> void:
	# Helper method to add entities to the hub
	map_data.entities.append(entity)
	entity.map_data = map_data
	entities.add_child(entity)

func remove_entity(entity: Entity) -> void:
	# Helper method to remove entities from the hub
	map_data.entities.erase(entity)
	if entity.get_parent() == entities:
		entities.remove_child(entity)

func enter_portal() -> void:
	var player: Entity = map_data.player
	if player and player.get_parent() == entities:
		entities.remove_child(player)

	for entity in entities.get_children():
		entity.queue_free()

	# The rest of the logic will be handled by game.gd
