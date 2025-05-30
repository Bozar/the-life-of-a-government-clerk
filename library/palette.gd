class_name Palette


# https://coolors.co/f8f9fa-e9ecef-dee2e6-ced4da-adb5bd-6c757d-495057-343a40-212529
const BACKGROUND_BLACK: String = "#212529"
const GREY: String = "#6C757D"
const DARK_GREY: String = "#343A40"
const LIGHT_GREY: String = "#ADB5BD"
const PC_GREY: String = "#DEE2E6"

# https://coolors.co/d8f3dc-b7e4c7-95d5b2-74c69d-52b788-40916c-2d6a4f-1b4332-081c15
const GREEN: String = "#52B788"
const DARK_GREEN: String = "#2D6A4F"
const PC_GREEN: String = "#95D5B2"
const DARK_PC_GREEN: String = "#40916C"

# https://coolors.co/f8b945-dc8a14-b9690b-854e19-a03401
const ORANGE: String = "#F8B945"
const DARK_ORANGE: String = "#854E19"

const DEBUG: String = "#FE4A49"
const INVALID_COLORS: Array = [DEBUG, DEBUG]


const DEFAULT_PALETTE: Dictionary = {
	MainTag.BACKGROUND: [BACKGROUND_BLACK, BACKGROUND_BLACK],
	MainTag.GUI_TEXT: [LIGHT_GREY, GREY],

	MainTag.GROUND: [GREY, DARK_GREY],
	MainTag.TRAP: [ORANGE, DARK_ORANGE],
	MainTag.BUILDING: [GREY, DARK_GREY],
	MainTag.ACTOR: [GREEN, DARK_GREEN],
	MainTag.INDICATOR: [DARK_GREY, GREY],

	SubTag.PC: [PC_GREEN, DARK_PC_GREEN],
}


const HTML_COLOR_REGEX: String = "^#{0,1}([0-9A-Fa-f]{3}){1,2}$"


# https://docs.godotengine.org/en/stable/tutorials/best_practices/autoloads_versus_internal_nodes.html
static var _color_regex: RegEx = RegEx.new()
static var _color_regex_compiled: bool = false


static func get_color(
		palette: Dictionary, main_tag: StringName, sub_tag: StringName,
		is_default_color: bool
) -> String:
	var default_main: Array = DEFAULT_PALETTE.get(main_tag, INVALID_COLORS)
	var palette_main: Array = palette.get(main_tag, default_main)
	var default_sub: Array = DEFAULT_PALETTE.get(sub_tag, palette_main)
	var colors: Array = palette.get(sub_tag, default_sub)

	if is_default_color:
		return colors[0]
	return colors[1]


static func get_verified_palette(palette: Dictionary) -> Dictionary:
	var colors: Array
	var verified_palettd: Dictionary = {}

	_compile_color_regex()
	for i: StringName in palette.keys():
		if not palette[i] is Array:
			continue
		colors = palette[i]
		if not _is_valid_color_array(colors):
			continue
		verified_palettd[i] = colors.duplicate()
	return verified_palettd


static func _is_valid_color_array(colors: Array) -> bool:
	if colors.size() != 2:
		return false
	for i: Variant in colors:
		if not i is String:
			return false
		if _color_regex.search(i as String) == null:
			return false
	return true


static func _compile_color_regex() -> void:
	if _color_regex_compiled:
		return
	if _color_regex.compile(HTML_COLOR_REGEX) == OK:
		_color_regex_compiled = true

