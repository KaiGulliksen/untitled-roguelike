class_name Game
extends Node2D

signal player_created(player)

const player_definition: EntityDefinition = preload("res://Assets/Definitions/Actors/entity_definition_player.tres")
const tile_size = 16

enum GameState { HUB, DUNGEON }

@onready var player: Entity
@onready var input_handler: InputHandler = $InputHandler
@onready var map: Map = $Map
@onready var hub: Hub = $Hub
@onready var camera: Camera2D = $Camera2D

var current_state: GameState = GameState.HUB
var current_location  # Will be either hub or map

func _ready() -> void:
	player = Entity.new(null, Vector2i.ZERO, player_definition)
	player_created.emit(player)
	remove_child(camera)
	player.add_child(camera)
	map.update_fov(player.grid_position)
	
	# Start in hub
	_enter_hub()
	
	MessageLog.send_message.bind(
		"Hello, adventurer. Welcome to the Hub!",
		GameColors.WELCOME_TEXT
	).call_deferred()
	camera.make_current.call_deferred()

	SignalBus.enter_portal.connect(_enter_dungeon)

func _enter_hub() -> void:
	current_state = GameState.HUB
	current_location = hub
	
	# Hide map, show hub
	map.visible = false
	hub.visible = true
	
	# Initialize hub with player
	hub.new(player)

func _enter_dungeon() -> void:
	if current_state == GameState.DUNGEON:
		return  # Already in the dungeon

	current_state = GameState.DUNGEON
	current_location = map

	hub.visible = false
	map.visible = true

	# Ensure player has a valid parent before removing
	if player.get_parent():
		player.get_parent().remove_child(player)
	
	map.add_child(player)
	map.generate(player)
	map.update_fov(player.grid_position)

	MessageLog.send_message.bind(
		"You enter the dangerous dungeon!",
		GameColors.WELCOME_TEXT
	).call_deferred()
	camera.make_current.call_deferred()

func _physics_process(_delta: float) -> void:
	var action: Action = await input_handler.get_action(player)
	if action:
		var previous_player_position: Vector2i = player.grid_position
		if action.perform():
			_handle_enemy_turns()
			
			# Update FOV based on current location
			if current_state == GameState.HUB:
				hub.update_fov(player.grid_position)
			else:
				map.update_fov(player.grid_position)

func _handle_enemy_turns() -> void:
	# Iterate over a copy, as the entities array might change during a turn.
	for entity in get_map_data().entities.duplicate():
		# The is_alive() check is all we need.
		if entity and entity != player and entity.is_alive():
			entity.ai_component.perform()

func get_map_data() -> MapData:
	if current_state == GameState.HUB:
		return hub.map_data
	else:
		return map.map_data

# Call this method to transition from hub to dungeon
func start_dungeon() -> void:
	_enter_dungeon()

# Call this method to return to hub
func return_to_hub() -> void:
	_enter_hub()
