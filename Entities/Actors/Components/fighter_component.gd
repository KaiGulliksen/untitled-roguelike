class_name FighterComponent
extends Component


signal hp_changed(hp, max_hp)


var max_hp: int
var hp: int:
	set(value):
		hp = clampi(value, 0, max_hp)
		hp_changed.emit(hp, max_hp)
		if hp <= 0:
			die()
var defense: int
var power: int

var death_texture: Texture
var death_color: Color


func _init(definition: FighterComponentDefinition) -> void:
	max_hp = definition.max_hp
	hp = definition.max_hp
	defense = definition.defense
	power = definition.power
	death_texture = definition.death_texture
	death_color = definition.death_color
	
func heal(amount: int) -> int:
	if hp == max_hp:
		return 0
	
	var new_hp_value: int = hp + amount
	
	if new_hp_value > max_hp:
		new_hp_value = max_hp
		
	var amount_recovered: int = new_hp_value - hp
	hp = new_hp_value
	return amount_recovered
	
func take_damage(amount: int) -> void:
	hp -= amount


func die() -> void:
	var death_message: String
	var death_message_color: Color
	
	if get_map_data().player == entity:
		death_message = "You died!"
		death_message_color = GameColors.PLAYER_DIE
		SignalBus.player_died.emit()
	else:
		death_message = "%s is dead!" % entity.get_entity_name()
		death_message_color = GameColors.ENEMY_DIE
		# Handle item drops
		_handle_drops()
	
	MessageLog.send_message(death_message, death_message_color)
	entity.texture = death_texture
	entity.modulate = death_color
	entity.ai_component.queue_free()
	entity.ai_component = null
	entity.entity_name = "Remains of %s" % entity.entity_name
	entity.blocks_movement = false
	entity.type = Entity.EntityType.CORPSE
	get_map_data().unregister_blocking_entity(entity)

func _handle_drops() -> void:
	if entity._definition == null or entity._definition.drop_table == null:
		return
	
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	var drops = entity._definition.drop_table.get_drops(rng)
	var map_data = get_map_data()
	
	for item_definition in drops:
		# Create the dropped item at the entity's position
		var dropped_item = Entity.new(map_data, entity.grid_position, item_definition)
		map_data.entities.append(dropped_item)
		# Emit the signal to add the item to the scene
		map_data.entity_placed.emit(dropped_item)
		
		var item_message = "%s dropped %s!" % [entity.get_entity_name(), item_definition.name]
		MessageLog.send_message(item_message, Color.YELLOW)
