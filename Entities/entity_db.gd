extends Node

# Enum for player character and monsters
enum EntityType {
	PLAYER,
	ZOMBIE,
	STIMPAK,
	CREDITS,
}


const entity_definitions = {
	EntityType.PLAYER: preload("res://Assets/Definitions/Actors/entity_definition_player.tres"),
	EntityType.ZOMBIE: preload("res://Assets/Definitions/Actors/entity_definition_zombie.tres"),
	EntityType.STIMPAK: preload("res://Assets/Definitions/Items/stimpak_definition.tres"),
	EntityType.CREDITS: preload("res://Assets/Definitions/Items/credits_definition.tres"),
}
