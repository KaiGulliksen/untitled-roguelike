class_name GameArea
extends Node2D

@export var fov_radius: int = 10
var map_data: MapData

@onready var entities: Node2D = $Entities
@onready var field_of_view: FieldOfView = $FieldOfView

signal entity_added(entity: Entity)
signal entity_removed(entity: Entity)

func _ready() -> void:
	# Ensure required nodes exist
	if not has_node("Entities"):
		entities = Node2D.new()
		entities.name = "Entities"
		add_child(entities)
	
	if not has_node("FieldOfView"):
		field_of_view = FieldOfView.new()
		field_of_view.name = "FieldOfView"
		add_child(field_of_view)

func initialize_map_data(width: int, height: int, player: Entity) -> void:
	map_data = MapData.new(width, height, player)
	if map_data.has_signal("entity_placed"):
		map_data.entity_placed.connect(_on_entity_placed)

func add_entity(entity: Entity) -> void:
	if not map_data.entities.has(entity):
		map_data.entities.append(entity)
	
	entity.map_data = map_data
	entities.add_child(entity)
	entity_added.emit(entity)

func remove_entity(entity: Entity) -> void:
	map_data.entities.erase(entity)
	if entity.get_parent() == entities:
		entities.remove_child(entity)
	entity_removed.emit(entity)

func _on_entity_placed(entity: Entity) -> void:
	entities.add_child(entity)

func update_fov(player_position: Vector2i) -> void:
	if not map_data:
		push_error("update_fov called before map_data is initialized")
		return
		
	field_of_view.update_fov(map_data, player_position, fov_radius)
	_update_entity_visibility()

func _update_entity_visibility() -> void:
	for entity in map_data.entities:
		if not entity:
			continue
			
		var tile = map_data.get_tile(entity.grid_position)
		if tile:
			entity.visible = tile.is_in_view
		else:
			entity.visible = false
			push_warning("Entity at invalid position: " + str(entity.grid_position))

func clear_entities() -> void:
	for entity in entities.get_children():
		entity.queue_free()
	map_data.entities.clear()

# Virtual methods for subclasses to override
func setup_area(player: Entity) -> void:
	pass

func cleanup_area() -> void:
	pass
