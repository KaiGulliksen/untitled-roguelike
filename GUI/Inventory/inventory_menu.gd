class_name InventoryMenu
extends CanvasLayer

signal menu_closed
signal item_selected

const inventory_menu_item_scene := preload("res://GUI/Inventory/inventory_menu_item.tscn")

@onready var inventory_list: VBoxContainer = $"%InventoryList"
@onready var inventory_item_label: Label = $"%InventoryItemLabel"

var inventory_component: InventoryComponent
var item_slots: Dictionary = {} # Maps items to their slot UI

func _ready() -> void:
	pass


func build(window_title: String, inventory_component: InventoryComponent) -> void:
	self.inventory_component = inventory_component
	inventory_item_label.text = window_title
	
	# Clear any existing items
	for child in inventory_list.get_children():
		child.queue_free()
	item_slots.clear()
	
	# Group items by name for stacking
	var stacked_items: Dictionary = {}
	for item in inventory_component.items:
		var item_name = item.get_entity_name()
		if not stacked_items.has(item_name):
			stacked_items[item_name] = []
		stacked_items[item_name].append(item)
	
	# Create slot for each unique item type
	var slot_index = 0
	for item_name in stacked_items:
		var items_of_type = stacked_items[item_name]
		var first_item = items_of_type[0]
		var quantity = items_of_type.size()
		
		# Create item slot
		var item_slot = inventory_menu_item_scene.instantiate()
		inventory_list.add_child(item_slot)
		
		# Configure the slot
		_setup_item_slot(first_item, quantity, slot_index)
		
		# Store reference for all items of this type
		for item in items_of_type:
			item_slots[item] = item_slot
		
		slot_index += 1
	
	# Show empty message if no items
	if inventory_component.items.is_empty():
		var empty_label = Label.new()
		empty_label.text = "Inventory is empty"
		empty_label.modulate = Color(0.7, 0.7, 0.7)
		inventory_list.add_child(empty_label)

func _setup_item_slot(item: Entity, quantity: int, index: int) -> void:
	var name_label = get_node("%InventoryItemLabel")
	var quantity_label = get_node("%QuantityLabel")
	
	# Add index letter for keyboard selection
	var letter = char(97 + index) # 'a', 'b', 'c', etc.
	name_label.text = "(%s) %s" % [letter, item.get_entity_name()]
	
	# Show quantity if more than 1
	if quantity > 1:
		quantity_label.text = "x%d" % quantity
		quantity_label.visible = true
	else:
		quantity_label.visible = false
	
	# Add hover effect
	#slot.mouse_entered.connect(_on_slot_hover.bind(slot, true))
	#slot.mouse_exited.connect(_on_slot_hover.bind(slot, false))
	
	# Add click handling for item selection
	#slot.gui_input.connect(_on_slot_input.bind(item))
	
	# Store item reference in slot
	set_meta("item", item)
	set_meta("index", index)

#func _on_close_pressed() -> void:
	#menu_closed.emit()
	#queue_free()

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_back") or Input.is_action_just_pressed("inventory"):
		item_selected.emit(null)
		menu_closed.emit()
		queue_free()

func button_pressed(item: Entity = null) -> void:
	item_selected.emit(item)
	menu_closed.emit()
	queue_free()
