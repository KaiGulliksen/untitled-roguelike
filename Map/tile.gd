class_name Tile
extends Sprite2D


var _definition: TileDefinition
var tile_key: TileDB.TileType


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

func _init(grid_position: Vector2i, tile_key: TileDB.TileType) -> void:
	visible = false
	centered = false
	position = Grid.grid_to_world(grid_position)
	set_tile_type(tile_key)
	
func set_tile_type(tile_key: TileDB.TileType) -> void:
	self.tile_key = tile_key
	_definition = TileDB.tile_types[tile_key]
	texture = _definition.texture
	modulate = _definition.color_dark

func is_walkable() -> bool:
	return _definition.is_walkable
	
func is_transparent() -> bool:
	return _definition.is_transparent
	
func is_portal() -> bool:
	return _definition.is_portal


func get_save_data() -> Dictionary:
	return {
		"key": tile_key,
		"is_explored": is_explored
	}


func restore(save_data: Dictionary) -> void:
	set_tile_type(save_data["key"])
	is_explored = save_data["is_explored"]
