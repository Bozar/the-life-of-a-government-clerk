class_name MenuScreen


const TRUE: String = "true"
const FALSE: String = "false"
const MAX_INT: int = 2 ** 32 - 1

const SCROLL_TEMPLATE: String = "%sScroll"
const LABEL_TEMPLATE: String = "%sScroll/%sLabel"

const SCROLL_LINE: int = 20
const SCROLL_PAGE: int = 300


static func set_size(
		container: MarginContainer, left: int,
		top: int = left, right: int = left, bottom: int = left
) -> void:
	container.size = Vector2(800, 600)
	container.add_theme_constant_override("margin_left", left)
	container.add_theme_constant_override("margin_top", top)
	container.add_theme_constant_override("margin_right", right)
	container.add_theme_constant_override("margin_bottom", bottom)


static func get_int(line_edit_text: String) -> int:
	var text_to_int: int = int(line_edit_text)

	if text_to_int > MAX_INT:
		return 0
	return text_to_int


static func get_bool(line_edit_text: String) -> bool:
	var text: String = line_edit_text.strip_edges().to_lower()

	match text:
		TRUE:
			return true
		FALSE:
			return false
		_:
			return bool(int(text))


static func init_scroll_label(
		root: Node, node_names: Array, text_files: Array
) -> Array:
	var gui_nodes: Array
	var label: CustomLabel
	var file_name: String
	var parsed_file: ParsedFile
	var scroll: ScrollContainer

	for i: String in node_names:
		gui_nodes.push_back([
			root.get_node(SCROLL_TEMPLATE % i),
			root.get_node(LABEL_TEMPLATE % [i, i]),
		])

	for i: int in range(0, node_names.size()):
		scroll = _get_scroll_node(gui_nodes, i)
		scroll.mouse_filter = Control.MOUSE_FILTER_IGNORE

		label = _get_label_node(gui_nodes, i)
		label.init_gui()

		if i >= text_files.size():
			continue

		file_name = text_files[i]
		parsed_file = FileIo.read_as_text(file_name)
		if parsed_file.parse_success:
			label.text = parsed_file.output_text

	return gui_nodes


static func switch_screen(
		input_tag: StringName, gui_nodes: Array, current_index: int,
		is_default_screen: bool = false
) -> int:
	var move_step: int = 0
	var label: CustomLabel
	var scroll: ScrollContainer
	var new_index: int

	if is_default_screen:
		move_step = -current_index
	elif input_tag == InputTag.NEXT_SCREEN:
		move_step = 1
	elif input_tag == InputTag.PREVIOUS_SCREEN:
		move_step = -1

	label = _get_label_node(gui_nodes, current_index)
	scroll = _get_scroll_node(gui_nodes, current_index)

	label.visible = false
	scroll.mouse_filter = Control.MOUSE_FILTER_IGNORE

	new_index = _get_new_index(current_index, move_step, gui_nodes.size())
	label = _get_label_node(gui_nodes, new_index)
	scroll = _get_scroll_node(gui_nodes, new_index)

	label.visible = true
	scroll.mouse_filter = Control.MOUSE_FILTER_PASS
	scroll.scroll_vertical = 0

	return new_index


static func scroll_screen(
		input_tag: StringName, gui_nodes: Array, gui_index: int
) -> void:
	var scroll: ScrollContainer = _get_scroll_node(gui_nodes, gui_index)
	var distance: int

	match input_tag:
		InputTag.PAGE_TOP:
			distance = 0
			scroll.scroll_vertical = distance
		InputTag.PAGE_BOTTOM:
			distance = int(scroll.get_v_scroll_bar().max_value)
			scroll.scroll_vertical = distance
		_:
			distance = _get_scroll_distance(input_tag)
			scroll.scroll_vertical += distance


static func _get_new_index(
		this_index: int, move_step: int, max_index: int
) -> int:
	var next_index: int = this_index + move_step

	if next_index >= max_index:
		return 0
	elif next_index < 0:
		return max_index - 1
	return next_index


static func _get_scroll_node(
		gui_nodes: Array, gui_index: int
) -> ScrollContainer:
	return gui_nodes[gui_index][0]


static func _get_label_node(gui_nodes: Array, gui_index: int) -> CustomLabel:
	return gui_nodes[gui_index][1]


static func _get_scroll_distance(input_tag: StringName) -> int:
	var distance: int = 0

	match input_tag:
		InputTag.LINE_DOWN:
			distance = SCROLL_LINE
		InputTag.LINE_UP:
			distance = -SCROLL_LINE
		InputTag.PAGE_DOWN:
			distance = SCROLL_PAGE
		InputTag.PAGE_UP:
			distance = -SCROLL_PAGE
	return distance

