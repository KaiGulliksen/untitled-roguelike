extends Node

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
