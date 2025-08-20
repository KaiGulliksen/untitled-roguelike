class_name InventoryMenu
extends CanvasLayer

signal menu_closed
signal item_selected

const inventory_menu_item_scene := preload("res://GUI/Inventory/inventory_menu_item.tscn")

func _ready() -> void:
	pass


func build(window_title: String, inventory_component: InventoryComponent) -> void:
	pass

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
