class_name WaitHealAction
extends Action

var amount: int = 15

func perform() -> bool:
	var player: Entity = get_map_data().player
	var map_data: MapData = player.map_data
	
	# Check for nearby enemies first
	for actor in map_data.get_actors():
		if actor != player and map_data.get_tile(actor.grid_position).is_in_view:
			MessageLog.send_message("There are monsters nearby, you can't rest", GameColors.IMPOSSIBLE)
			return false
	
	# No enemies nearby, heal the player
	var amount_recovered: int = player.fighter_component.heal(amount)
	if amount_recovered > 0:
		MessageLog.send_message("You rest and recover your health.", Color.WHITE)
	else:
		MessageLog.send_message("You are already at full health.", Color.WHITE)
	return true
