class_name InventoryMenu
extends CanvasLayer

signal menu_closed

func _ready() -> void:
	pass


func build(window_title: String, inventory_component: InventoryComponent) -> void:
	pass

func _on_close_pressed() -> void:
	menu_closed.emit()
	queue_free()

func _input(event: InputEvent) -> void:
	# Allow closing with ESC or 'i' key
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("inventory"):
		_on_close_pressed()
		get_viewport().set_input_as_handled()
	
	# Allow closing with 'quit' action
	if event.is_action_pressed("quit"):
		_on_close_pressed()
		get_viewport().set_input_as_handled()
