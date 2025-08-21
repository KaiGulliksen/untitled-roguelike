class_name ItemSlot
extends PanelContainer

signal slot_clicked(item: Entity)
signal slot_hovered(item: Entity)

@onready var name_label: Label = $"%ItemNameLabel"
@onready var quantity_label: Label = $"%ItemQuantLabel"

var item: Entity
var quantity: int = 1
var slot_index: int = -1

func _ready() -> void:
	# Make sure the slot can receive mouse input
	mouse_filter = Control.MOUSE_FILTER_PASS
	
	# Optional: Add visual feedback styles
	_setup_styles()

func setup(item: Entity, quantity: int, index: int) -> void:
	self.item = item
	self.quantity = quantity
	self.slot_index = index
	
	# Update labels
	var letter = char(97 + index) # 'a', 'b', 'c', etc.
	name_label.text = "(%s) %s" % [letter, item.get_entity_name()]
	
	if quantity > 1:
		quantity_label.text = "x%d" % quantity
		quantity_label.visible = true
	else:
		quantity_label.visible = false

func _setup_styles() -> void:
	# You can customize the appearance here
	var default_style = get_theme_stylebox("panel").duplicate()
	add_theme_stylebox_override("panel", default_style)
	
	# Create hover style
	var hover_style = default_style.duplicate()
	if hover_style is StyleBoxFlat:
		hover_style.bg_color = Color(0.2, 0.2, 0.2, 0.8)
		hover_style.border_color = Color(0.6, 0.6, 0.6, 1)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			slot_clicked.emit(item)
	elif event is InputEventMouseMotion:
		slot_hovered.emit(item)

func highlight(is_highlighted: bool) -> void:
	if is_highlighted:
		modulate = Color(1.2, 1.2, 1.2)
	else:
		modulate = Color.WHITE

func set_selected(is_selected: bool) -> void:
	if is_selected:
		# Visual indicator for selected item
		var style = get_theme_stylebox("panel")
		if style is StyleBoxFlat:
			style.border_color = Color.YELLOW
			style.border_width_left = 2
			style.border_width_top = 2
			style.border_width_right = 2
			style.border_width_bottom = 2
	else:
		# Reset to default
		var style = get_theme_stylebox("panel")
		if style is StyleBoxFlat:
			style.border_color = Color(0.4, 0.4, 0.4, 1)
			style.border_width_left = 1
			style.border_width_top = 1
			style.border_width_right = 1
			style.border_width_bottom = 1
