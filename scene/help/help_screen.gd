class_name HelpScreen
extends CustomMarginContainer


const ORDERED_GUI_NAMES: Array = [
	"Keybinding",
	"Gameplay",
	"Introduction",
]
const ORDERED_TEXT_FILES: Array = [
	"res://user/doc/keybinding.md",
	"res://user/doc/gameplay.md",
	"res://user/doc/introduction.md",
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
	if (not self.visible) and (input_tag != InputTag.OPEN_HELP_MENU):
		return

	match input_tag:
		InputTag.OPEN_HELP_MENU:
			visible = true
			_current_index = MenuScreen.switch_screen(
					input_tag, _gui_nodes, _current_index,
					true
			)
		InputTag.CLOSE_MENU:
			visible = false
		InputTag.PREVIOUS_SCREEN, InputTag.NEXT_SCREEN:
			_current_index = MenuScreen.switch_screen(
					input_tag, _gui_nodes, _current_index
			)
		InputTag.PAGE_DOWN, InputTag.PAGE_UP, \
				InputTag.LINE_DOWN, InputTag.LINE_UP, \
				InputTag.PAGE_TOP, InputTag.PAGE_BOTTOM:
			MenuScreen.scroll_screen(
					input_tag, _gui_nodes, _current_index
			)

