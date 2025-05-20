class_name FootnoteLabel
extends CustomLabel


var VERSION: String = "0.1.1"


func init_gui() -> void:
	_set_font(false)
	text = "%s\n%s\n%s" % [
		_get_version(), _get_menu(), _get_seed()
	]


func _get_version() -> String:
	var wizard: String = "+" if TransferData.wizard_mode else ""

	return "%s%s" % [wizard, VERSION]


func _get_menu() -> String:
	return "Menu: C|V"


func _get_seed() -> String:
	var str_seed: String = "%d" % NodeHub.ref_RandomNumber.get_seed()
	var seed_len: int = str_seed.length()
	var head: String = str_seed.substr(0, 3)
	var body: String = ("-" + str_seed.substr(3, 3)) \
			if (seed_len > 3) \
			else ""
	var tail: String = ("-" + str_seed.substr(6)) \
			if (seed_len > 6) \
			else ""

	return "%s%s%s" % [head, body, tail]

