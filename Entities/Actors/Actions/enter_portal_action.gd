class_name EnterPortalAction
extends Action

func perform() -> bool:
	var map_data: MapData = get_map_data()
	var current_tile: Tile = map_data.get_tile(entity.grid_position)

	if current_tile and current_tile.is_portal():
		SignalBus.enter_portal.emit()
		MessageLog.send_message("You enter the portal!", GameColors.WELCOME_TEXT)
		# You can add your logic here for what happens when the player enters the portal.
		return true
	else:
		MessageLog.send_message("There is no portal here.", GameColors.IMPOSSIBLE)
		return false
