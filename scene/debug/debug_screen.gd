class_name DebugScreen
extends CustomMarginContainer


const GUI_NODES: Array = [
	"DebugVBox/TitleLabel",
	"DebugVBox/SettingGrid/SeedLabel",
	"DebugVBox/SettingGrid/WizardLabel",
	"DebugVBox/SettingGrid/MapLabel",
	"DebugVBox/SettingGrid/SeedLineEdit",
	"DebugVBox/SettingGrid/WizardLineEdit",
	"DebugVBox/SettingGrid/MapLineEdit",
]

const TRUE: String = "true"
const FALSE: String = "false"
const MAX_INT: int = 2 ** 32 - 1

const JSON_SETTING: String = '{"rng_seed":0,"wizard_mode":false,"show_full_map":false,"palette":{},"HELP":{"VALID_OPTION":["rng_seed","wizard_mode","show_full_map","palette"],"PALETTES":{"GREY":"https://coolors.co/f8f9fa-e9ecef-dee2e6-ced4da-adb5bd-6c757d-495057-343a40-212529","GREEN":"https://coolors.co/d8f3dc-b7e4c7-95d5b2-74c69d-52b788-40916c-2d6a4f-1b4332-081c15","ORANGE":"https://coolors.co/f8b945-dc8a14-b9690b-854e19-a03401"}},"DEFAULT_PALETTE":{"background":["#212529","#212529"],"gui_text":["#ADB5BD","#6C757D"],"ground":["#6C757D","#343A40"],"trap":["#F8B945","#854E19"],"building":["#6C757D","#343A40"],"actor":["#52B788","#2D6A4F"],"indicator":["#343A40","#6C757D"],"pc":["#95D5B2","#40916C"]},"BLUE_PALETTE":{"actor":["56ADD8","0E628C"]},"GREY_PALETTE":{"trap":["#ADB5BD","#6C757D"],"actor":["#ADB5BD","#6C757D"],"pc":["#DEE2E6","#6C757D"]}}'


@onready var _ref_SeedLineEdit: CustomLineEdit \
		= $DebugVBox/SettingGrid/SeedLineEdit
@onready var _ref_WizardLineEdit: CustomLineEdit \
		= $DebugVBox/SettingGrid/WizardLineEdit
@onready var _ref_MapLineEdit: CustomLineEdit \
		= $DebugVBox/SettingGrid/MapLineEdit


func _ready() -> void:
	visible = false
	size = Vector2(800, 600)
	add_theme_constant_override("margin_left", 60)
	add_theme_constant_override("margin_top", 40)
	add_theme_constant_override("margin_right", 60)
	add_theme_constant_override("margin_bottom", 60)

	$DebugVBox.add_theme_constant_override("separation", 40)

	$DebugVBox/SettingGrid.columns = 2
	$DebugVBox/SettingGrid.add_theme_constant_override("h_separation", 10)
	$DebugVBox/SettingGrid.add_theme_constant_override("v_separation", 10)

	$DebugVBox/SettingGrid/SeedLineEdit.size_flags_horizontal \
			= SIZE_EXPAND_FILL


func init_gui() -> void:
	for i: String in GUI_NODES:
		get_node(i).init_gui()


# NOTE: Delete `ui_cancel` key in `Input Map`.
func _on_SignalHub_action_pressed(input_tag: StringName) -> void:
	match input_tag:
		InputTag.CLOSE_MENU:
			visible = false
		InputTag.OPEN_DEBUG_MENU:
			_ref_SeedLineEdit.grab_focus()
			visible = true
		InputTag.REPLAY_GAME, InputTag.RESTART_GAME, \
				InputTag.START_NEW_GAME:
			_set_transfer_data(input_tag)
		InputTag.COPY_SETTING:
			DisplayServer.clipboard_set(JSON_SETTING)


func _set_transfer_data(input_tag: StringName) -> void:
	if input_tag != InputTag.REPLAY_GAME:
		TransferData.set_rng_seed(_get_int(_ref_SeedLineEdit.text))
	TransferData.set_wizard_mode(_get_bool(_ref_WizardLineEdit.text))
	TransferData.set_show_full_map(_get_bool(_ref_MapLineEdit.text))


func _get_int(line_edit_text: String) -> int:
	var text_to_int: int = int(line_edit_text)

	if text_to_int > MAX_INT:
		return 0
	return text_to_int


func _get_bool(line_edit_text: String) -> bool:
	var text: String = line_edit_text.strip_edges().to_lower()

	match text:
		TRUE:
			return true
		FALSE:
			return false
		_:
			return bool(int(text))

