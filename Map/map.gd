class_name Map
extends Node2D


@export var fov_radius: int = 10

var map_data: MapData

@onready var tiles: Node2D = $Tiles
@onready var entities: Node2D = $Entities
@onready var dungeon_generator: DungeonGenerator = $DungeonGenerator
@onready var field_of_view: FieldOfView = $FieldOfView


func generate(player: Entity) -> void:
	map_data = dungeon_generator.generate_dungeon(player)
	map_data.entity_placed.connect(entities.add_child)
	_place_tiles()
	_place_entities()
	
func _place_tiles() -> void:
	for tile in map_data.tiles:
		tiles.add_child(tile)
		
func _place_entities() -> void:
	for entity in map_data.entities:
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
