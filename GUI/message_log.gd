class_name MessageLog
extends ScrollContainer

var last_message: Message = null

@onready var message_list: VBoxContainer = $"%MessageList"

func _ready() -> void:
	SignalBus.message_sent.connect(add_message)
	# Set the scroll container to always show the scrollbar for consistency
	vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_ALWAYS
	
static func send_message(text: String, color: Color) -> void:
	SignalBus.message_sent.emit(text, color)

func add_message(text: String, color: Color) -> void:
	if last_message != null and last_message.plain_text == text:
		last_message.count += 1
	else:
		var message := Message.new(text, color)
		last_message = message
		message_list.add_child(message)
	
	# Single deferred call
	call_deferred("_scroll_to_bottom")

func _scroll_to_bottom() -> void:
	await get_tree().process_frame
	var v_scrollbar = get_v_scroll_bar()
	if v_scrollbar:
		scroll_vertical = v_scrollbar.max_value
