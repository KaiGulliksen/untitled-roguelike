class_name DropTable
extends Resource

@export var drops: Array[DropEntry] = []

func get_drops(rng: RandomNumberGenerator) -> Array[EntityDefinition]:
	var dropped_items: Array[EntityDefinition] = []
	
	for drop_entry in drops:
		if drop_entry.should_drop(rng):
			dropped_items.append(drop_entry.item)
	
	return dropped_items
