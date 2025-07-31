class_name WaitHealAction
extends Action

var amount: int = 15

# Allows the player to wait and passively heal if there are no monsters in view


func perform() -> bool:
	var player: Entity = get_map_data().player
	var target: Entity = null
	var map_data: MapData = player.map_data
	var amount_recovered: int = player.fighter_component.heal(amount)
	var hp: int = entity.fighter_component.hp
	var max_hp: int = entity.fighter_component.max_hp
	
	for actor in map_data.get_actors():
		if actor != player and map_data.get_tile(actor.grid_position).is_in_view:
			MessageLog.send_message("There are monsters nearby, you can't rest", GameColors.IMPOSSIBLE)
			return false
			
		if actor != player and map_data.get_tile(actor.grid_position).is_in_view:
			hp = hp + amount_recovered
			MessageLog.send_message("You rest and recover your health.", Color.WHITE)
			return true
	
	
	return true
