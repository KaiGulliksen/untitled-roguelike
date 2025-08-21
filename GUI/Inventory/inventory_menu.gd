class_name InventoryMenu
extends CanvasLayer

signal menu_closed
signal item_selected(item: Entity)
signal item_used(item: Entity)  # New signal for using items
signal item_dropped(item: Entity)  # New signal for dropping items

const inventory_menu_item_scene := preload("res://GUI/Inventory/item_slot.tscn")

@onready var inventory_list: VBoxContainer = $"%InventoryList"
@onready var inventory_item_label: Label = $"%InventoryItemLabel"

var inventory_component: InventoryComponent
var item_slots: Array = [] # Array of slots for navigation
var selected_index: int = 0
var items_array: Array[Entity] = [] # Keep track of items in order

func _ready() -> void:
	pass

func build(window_title: String, inventory_component: InventoryComponent) -> void:
	self.inventory_component = inventory_component
	#title_label.text = window_title
	
	# Clear any existing items
	for child in inventory_list.get_children():
		child.queue_free()
	item_slots.clear()
	items_array.clear()
	selected_index = 0
	
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
		_setup_item_slot(item_slot, first_item, quantity, slot_index)
		
		# Store reference
		item_slots.append(item_slot)
		items_array.append(first_item)
		
		slot_index += 1
	
	# Show empty message if no items
	if inventory_component.items.is_empty():
		var empty_label = Label.new()
		empty_label.text = "Inventory is empty"
		empty_label.modulate = Color(0.7, 0.7, 0.7)
		inventory_list.add_child(empty_label)
	else:
		# Highlight first item
		_update_selection()

func _setup_item_slot(slot: PanelContainer, item: Entity, quantity: int, index: int) -> void:
	var name_label = slot.get_node("%ItemNameLabel")
	var quantity_label = slot.get_node("%ItemQuantLabel")
	
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
	slot.mouse_entered.connect(_on_slot_hover.bind(slot, true))
	slot.mouse_exited.connect(_on_slot_hover.bind(slot, false))
	
	# Add click handling for item selection
	#slot.gui_input.connect(_on_slot_input.bind(item))
	
	# Store item reference in slot
	set_meta("item", item)
	set_meta("index", index)

func _update_selection() -> void:
	# Clear all highlights
	for i in range(item_slots.size()):
		var slot = item_slots[i]
		if i == selected_index:
			# Highlight selected
			slot.modulate = Color(1.5, 1.5, 1.5)
			var style = slot.get_theme_stylebox("panel")
			if style and style is StyleBoxFlat:
				var new_style = style.duplicate()
				new_style.border_color = Color.YELLOW
				new_style.border_width_left = 2
				new_style.border_width_top = 2
				new_style.border_width_right = 2
				new_style.border_width_bottom = 2
				slot.add_theme_stylebox_override("panel", new_style)
		else:
			# Remove highlight
			slot.modulate = Color.WHITE
			var style = slot.get_theme_stylebox("panel")
			if style and style is StyleBoxFlat:
				var new_style = style.duplicate()
				new_style.border_color = Color(0.4, 0.4, 0.4, 1)
				new_style.border_width_left = 1
				new_style.border_width_top = 1
				new_style.border_width_right = 1
				new_style.border_width_bottom = 1
				slot.add_theme_stylebox_override("panel", new_style)

func _on_slot_hover(slot: PanelContainer, is_hovering: bool) -> void:
	if is_hovering:
		slot.modulate = Color(1.2, 1.2, 1.2)
	else:
		slot.modulate = Color.WHITE

#func _on_close_pressed() -> void:
	#menu_closed.emit()
	#queue_free()

func _input(event: InputEvent) -> void:
	# Handle navigation with direction keys
	if event.is_action_pressed("ui_up"):
		if selected_index > 0:
			selected_index -= 1
			_update_selection()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_down"):
		if selected_index < item_slots.size() - 1:
			selected_index += 1
			_update_selection()
		get_viewport().set_input_as_handled()
	
	# Handle item activation with "activate" key (Enter)
	elif event.is_action_pressed("activate"):
		if selected_index < items_array.size():
			var item = items_array[selected_index]
			if item.consumable_component:
				item_used.emit(item)
			else:
				MessageLog.send_message("You can't use the %s." % item.get_entity_name(), GameColors.IMPOSSIBLE)
		get_viewport().set_input_as_handled()
	
	# Handle item dropping with "drop" key
	elif event.is_action_pressed("drop"):
		if selected_index < items_array.size():
			var item = items_array[selected_index]
			item_dropped.emit(item)
		get_viewport().set_input_as_handled()

	elif event is InputEventKey and event.pressed:
		var key_code = event.keycode
		# Check if it's a letter key (A-Z)
		if key_code >= KEY_A and key_code <= KEY_Z:
			var index = key_code - KEY_A
			if index < items_array.size():
				selected_index = index
				_update_selection()
				# Immediately use the item
				var item = items_array[index]
				if item.consumable_component:
					item_used.emit(item)
				else:
					MessageLog.send_message("You can't use the %s." % item.get_entity_name(), GameColors.IMPOSSIBLE)
			get_viewport().set_input_as_handled()

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_back") or Input.is_action_just_pressed("inventory"):
		item_selected.emit(null)
		menu_closed.emit()
		queue_free()

func button_pressed(item: Entity = null) -> void:
	item_selected.emit(item)
	menu_closed.emit()
	queue_free()
