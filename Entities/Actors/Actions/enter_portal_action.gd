class_name EnterPortalAction
extends Action

func perform() -> bool:
	var map_data: MapData = get_map_data()
	var current_tile: Tile = map_data.get_tile(entity.grid_position)

	if current_tile and current_tile.is_portal():
		var game_node = entity.get_tree().get_root().find_child("Game", true, false)
		if game_node:
			game_node.call_deferred("_enter_dungeon")
		MessageLog.send_message("You enter the portal!", GameColors.WELCOME_TEXT)
		return true
	else:
		MessageLog.send_message("There is no portal here.", GameColors.IMPOSSIBLE)
		return false
