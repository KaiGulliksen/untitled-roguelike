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
	if (
		last_message != null and 
		last_message.plain_text == text
	):
		last_message.count += 1
	else:
		var message := Message.new(text, color)
		last_message = message
		message_list.add_child(message)
	
	# Multiple deferred calls to ensure scrolling happens after all UI updates
	call_deferred("_prepare_scroll")

func _prepare_scroll() -> void:
	# Force the container to update its size
	message_list.queue_sort()
	call_deferred("_do_scroll")

func _do_scroll() -> void:
	# Wait one more frame to be absolutely sure
	await get_tree().process_frame
	
	# Force scroll to bottom with multiple approaches
	var v_scrollbar = get_v_scroll_bar()
	if v_scrollbar:
		# Set to max value
		scroll_vertical = v_scrollbar.max_value
		# Force the scrollbar to update
		v_scrollbar.value = v_scrollbar.max_value
		
	# Also try ensure_control_visible as backup
	if last_message and is_instance_valid(last_message):
		ensure_control_visible(last_message)
		
	# One more deferred update just to be sure
	call_deferred("_final_scroll")

func _final_scroll() -> void:
	var v_scrollbar = get_v_scroll_bar()
	if v_scrollbar:
		scroll_vertical = v_scrollbar.max_value
