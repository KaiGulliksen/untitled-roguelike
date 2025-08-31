extends Node


enum EntityType {CORPSE, ITEM, ACTOR}
enum AIType {NONE, HOSTILE}

# Enum for player character and monsters
enum Actors {
	PLAYER,
	ZOMBIE,
}

# Enum for consumable and other items
enum Items {
	STIMPAK,
	CREDITS,
}

# Placeholder enum for future equipment
enum Equipment {
	# To be added later
}


const actor_definitions = {
	Actors.PLAYER: preload("res://Assets/Definitions/Actors/entity_definition_player.tres"),
	Actors.ZOMBIE: preload("res://Assets/Definitions/Actors/entity_definition_zombie.tres"),
}

const item_definitions = {
	Items.STIMPAK: preload("res://Assets/Definitions/Items/stimpak_definition.tres"),
	Items.CREDITS: preload("res://Assets/Definitions/Items/credits_definition.tres"),
}

const equipment_definitions = {
	# To be added later
}
