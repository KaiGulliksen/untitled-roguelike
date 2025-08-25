class_name Tile
extends Sprite2D


enum TileType {
	FLOOR1,
	WALL1,
	PORTAL1,
}


const tile_types = {
	TileType.FLOOR1: preload("res://Assets/Definitions/Tiles/tile_definition_floor.tres"),
	TileType.WALL1: preload("res://Assets/Definitions/Tiles/tile_definition_wall.tres"),
	TileType.PORTAL1: preload("res://Assets/Definitions/Tiles/tile_definition_portal.tres"),
	}


var _definition: TileDefinition
var tile_key: TileType

var is_explored: bool = false:
	set(value):
		is_explored = value
		if is_explored and not visible:
			visible = true
			
var is_in_view: bool = false:
	set(value):
		is_in_view = value
		modulate = _definition.color_lit if is_in_view else _definition.color_dark
		if is_in_view and not is_explored:
			is_explored = true

func _init(grid_position: Vector2i, p_tile_key: TileType) -> void:
	visible = false
	centered = false
	position = Grid.grid_to_world(grid_position)
	set_tile_type(p_tile_key)
	
func set_tile_type(p_tile_key: TileType) -> void:
	self.tile_key = p_tile_key
	_definition = tile_types[p_tile_key]
	texture = _definition.texture
	modulate = _definition.color_dark

func is_walkable() -> bool:
	return _definition.is_walkable
	
func is_transparent() -> bool:
	return _definition.is_transparent
	
func is_portal() -> bool:
	return _definition.is_portal
