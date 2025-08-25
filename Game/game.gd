class_name Game
extends Node2D

signal player_created(player)

#const player_definition: EntityDefinition = preload("res://Assets/Definitions/Actors/entity_definition_player.tres")

enum GameState { HUB, DUNGEON }

@onready var player: Entity
@onready var input_handler: InputHandler = $InputHandler
@onready var map: Map = $Map
@onready var hub: Hub = $Hub
@onready var camera: Camera2D = $Camera2D

var player_def: EntityDefinition = EntityDB.actor_definitions[EntityDB.Actors.PLAYER]
var current_state: GameState = GameState.HUB
var current_area: GameArea  # Now using the base class type

func _ready() -> void:	
	player = Entity.new(null, Vector2i.ZERO, player_def)
	player_created.emit(player)
	
	# Move camera to player
	remove_child(camera)
	player.add_child(camera)
	
	_enter_hub()
	
	MessageLog.send_message(
		"Hello, adventurer. Welcome to the Hub!",
		GameColors.WELCOME_TEXT
	)
	camera.make_current.call_deferred()
	SignalBus.enter_portal.connect(_enter_dungeon)

func _enter_hub() -> void:
	current_state = GameState.HUB
	_transition_to_area(hub)
	
	MessageLog.send_message(
		"You return to the safety of the Hub.",
		GameColors.WELCOME_TEXT
	)

func _enter_dungeon() -> void:
	if current_state == GameState.DUNGEON:
		return
		
	current_state = GameState.DUNGEON
	_transition_to_area(map)
	
	# Map needs special generation logic
	map.generate(player)
	
	MessageLog.send_message(
		"You enter the dangerous dungeon!",
		GameColors.WELCOME_TEXT
	)

# Unified transition method - works for any GameArea
func _transition_to_area(new_area: GameArea) -> void:
	# Hide current area
	if current_area:
		current_area.visible = false
		current_area.cleanup_area()
		
		# Remove player from current area
		if player.get_parent() and player.get_parent() != self:
			current_area.remove_entity(player)
	
	# Show and setup new area
	current_area = new_area
	current_area.visible = true
	current_area.setup_area(player)
	current_area.update_fov(player.grid_position)
	
	# Make camera current after transition
	camera.make_current.call_deferred()

func _physics_process(_delta: float) -> void:
	var action: Action = await input_handler.get_action(player)
	if action:
		if action.perform():
			_handle_enemy_turns()
			current_area.update_fov(player.grid_position)

func _handle_enemy_turns() -> void:
	# Works with any GameArea now
	for entity in current_area.map_data.entities.duplicate():
		if entity and entity != player and entity.is_alive():
			entity.ai_component.perform()

func get_map_data() -> MapData:
	return current_area.map_data if current_area else null

# Simplified transition methods
func start_dungeon() -> void:
	_enter_dungeon()

func return_to_hub() -> void:
	_enter_hub()
