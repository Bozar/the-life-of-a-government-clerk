class_name ChallengeScreen
extends CustomMarginContainer


const ORDERED_GUI_NAMES: Array = [
	"Challenge",
]
const ORDERED_TEXT_FILES: Array = [
	"res://user/doc/challenge_list.md",
]


var _current_index: int = 0
var _gui_nodes: Array = []


func _ready() -> void:
	visible = false
	MenuScreen.set_size(self, 30)


func init_gui() -> void:
	_gui_nodes = MenuScreen.init_scroll_label(
			self, ORDERED_GUI_NAMES, ORDERED_TEXT_FILES
	)


func _on_SignalHub_action_pressed(input_tag: StringName) -> void:
	if (not self.visible) and (input_tag != InputTag.OPEN_CHALLENGE_MENU):
		return

	var label: CustomLabel

	match input_tag:
		InputTag.OPEN_CHALLENGE_MENU:
			visible = true
			_current_index = MenuScreen.switch_screen(
					input_tag, _gui_nodes, _current_index,
					true
			)
			label = MenuScreen.get_label_node(
					_gui_nodes, _current_index
			)
			_set_challenge_state(label)
		InputTag.CLOSE_MENU:
			visible = false
		InputTag.PAGE_DOWN, InputTag.PAGE_UP, \
				InputTag.LINE_DOWN, InputTag.LINE_UP, \
				InputTag.PAGE_TOP, InputTag.PAGE_BOTTOM:
			MenuScreen.scroll_screen(
					input_tag, _gui_nodes, _current_index
			)


func _set_challenge_state(label: CustomLabel) -> void:
	var state: int
	var states: Array

	for i: int in ChallengeTag.ALL_CHALLENGES:
		state = NodeHub.ref_DataHub.get_challenge_state(i)
		states.push_back(ChallengeTag.STATE_TO_STRING[state])
	label.text = label.text % states

