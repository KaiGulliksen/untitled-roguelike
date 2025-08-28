class_name Entity
extends Sprite2D


enum AIType {NONE, HOSTILE}
enum EntityType {CORPSE, ITEM, ACTOR}

var _definition: EntityDefinition
var entity_name: String
var blocks_movement: bool
var type: EntityType:
	set(value):
		type = value
		z_index = type
var map_data: MapData

var fighter_component: FighterComponent
var ai_component: BaseAIComponent
var inventory_component: InventoryComponent
var consumable_component: ConsumableComponent



var grid_position: Vector2i:
	set(value):
		grid_position = value
		position = Grid.grid_to_world(grid_position)
		
func _init(map_data: MapData, start_position: Vector2i, entity_definition: EntityDefinition) -> void:
	centered = false
	grid_position = start_position
	self.map_data = map_data
	set_entity_type(entity_definition)
	
func move(move_offset: Vector2i) -> void:
	map_data.unregister_blocking_entity(self)
	grid_position += move_offset
	map_data.register_blocking_entity(self)

func set_entity_type(entity_definition: EntityDefinition) -> void:
	_definition = entity_definition
	type = _definition.type
	blocks_movement = _definition.is_blocking_movement
	entity_name = _definition.name
	texture = entity_definition.texture
	modulate = entity_definition.color
	
	match entity_definition.ai_type:
		AIType.HOSTILE:
			ai_component = HostileEnemyAIComponent.new()
			add_child(ai_component)
			
	if entity_definition.fighter_definition:
		fighter_component = FighterComponent.new(entity_definition.fighter_definition)
		add_child(fighter_component)
		
	if entity_definition.item_definition:
		if entity_definition.item_definition is HealingConsumableComponentDefinition:
			consumable_component = HealingConsumableComponent.new(entity_definition.item_definition)
			add_child(consumable_component)
	
	if entity_definition.inventory_capacity > 0:
		inventory_component = InventoryComponent.new()
		inventory_component.capacity = entity_definition.inventory_capacity
		add_child(inventory_component)
		
func is_blocking_movement() -> bool:
	return blocks_movement
	
func get_entity_name() -> String:
	return entity_name
	
func is_alive() -> bool:
	return ai_component != null

# Get enitity distance from a certain position	
func distance(other_postition) -> int:
	var relative: Vector2i = other_postition - grid_position
	return maxi(abs(relative.x), abs(relative.y))



func get_save_data() -> Dictionary:
	var save_data: Dictionary = {
		"x": grid_position.x,
		"y": grid_position.y,
		"key": type,
	}
	if fighter_component:
		save_data["fighter_component"] = fighter_component.get_save_data()
	if ai_component:
		save_data["ai_component"] = ai_component.get_save_data()
	if inventory_component:
		save_data["inventory_component"] = inventory_component.get_save_data()
	return save_data

func restore(save_data: Dictionary) -> void:
	grid_position = Vector2i(save_data["x"], save_data["y"])
	set_entity_type(save_data["key"])
	if fighter_component and save_data.has("fighter_component"):
		fighter_component.restore(save_data["fighter_component"])
	if ai_component and save_data.has("ai_component"):
		var ai_data: Dictionary = save_data["ai_component"]
		#if ai_data["type"] == "ConfusedEnemyAI":
			#var confused_enemy_ai := ConfusedEnemyAIComponent.new(ai_data["turns_remaining"])
			#add_child(confused_enemy_ai)
	if inventory_component and save_data.has("inventory_component"):
		inventory_component.restore(save_data["inventory_component"])
