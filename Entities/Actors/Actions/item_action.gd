class_name ItemAction
extends Action

var item: Entity
var target_position: Vector2i


func _init(entity: Entity, item: Entity, target_position: Vector2i = Vector2i.ZERO) -> void:
	super._init(entity)
	self.item = item
	if target_position == Vector2i.ZERO:
		self.target_position = entity.grid_position
	else:
		self.target_position = target_position
	
func get_target_actor() -> Entity:
	return get_map_data().get_actor_at_location(target_position)
		
func perform() -> bool:
	if item == null:
		MessageLog.send_message("No item selected.", GameColors.IMPOSSIBLE)
		return false
	
	if item.consumable_component:
		return item.consumable_component.activate(self)
	else:
		MessageLog.send_message("You can't use the %s." % item.get_entity_name(), GameColors.IMPOSSIBLE)
		return false
