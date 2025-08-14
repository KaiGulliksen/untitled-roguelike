class_name DropEntry
extends Resource

@export var item: EntityDefinition
@export_range(0.0, 1.0) var drop_chance: float = 0.5
@export var min_quantity: int = 1
@export var max_quantity: int = 1

func should_drop(rng: RandomNumberGenerator) -> bool:
	return rng.randf() <= drop_chance

func get_quantity(rng: RandomNumberGenerator) -> int:
	if min_quantity == max_quantity:
		return min_quantity
	return rng.randi_range(min_quantity, max_quantity)
