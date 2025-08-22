class_name Map
extends GameArea

@onready var tiles: Node2D = $Tiles
@onready var dungeon_generator: DungeonGenerator = $DungeonGenerator

func _ready() -> void:
	super._ready()
	fov_radius = 10  # Dungeon-specific FOV radius

func generate(player: Entity) -> void:
	# Set the map_data for the player first
	player.map_data = dungeon_generator.generate_dungeon(player)
	self.map_data = player.map_data
	
	map_data.entity_placed.connect(entities.add_child)
	_place_tiles()
	_place_entities()

	# Ensure the player is in the entities node
	if not player.is_inside_tree():
		add_entity(player)
	
	update_fov(player.grid_position)

func _place_tiles() -> void:
	for tile in map_data.tiles:
		tiles.add_child(tile)
		
func _place_entities() -> void:
	for entity in map_data.entities:
		if entity != map_data.player:  # Player handled separately
			add_entity(entity)
