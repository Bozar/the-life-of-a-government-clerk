class_name StateLabel
extends CustomLabel


const TURN: String = "Turn: %1d"
const DOC: String = "Doc: %2d"
const CASH: String = "Cash: %1d-%1d"
const CALL: String = "Call: %1d-%1d"
const CART: String = "%s\n%s"

const YOU_WIN: String = "You win.\n[Enter]"
const YOU_LOSE: String = "You lose.\n[Enter]"


var game_over: bool = false
var player_win: bool = false


func init_gui() -> void:
	_set_font(true)
	update_gui()


func update_gui() -> void:
	var turn: String = TURN % NodeHub.ref_DataHub.turn_counter
	var doc: String = DOC % NodeHub.ref_DataHub.delivery
	var cash: String = CASH % [
		NodeHub.ref_DataHub.cash, NodeHub.ref_DataHub.account,
	]
	var phone_call: String = CALL % [
		NodeHub.ref_DataHub.incoming_call,
		NodeHub.ref_DataHub.remaining_call,
	]
	var cart: String
	var message: String

	match NodeHub.ref_DataHub.game_mode:
		GameData.NORMAL_MODE:
			cart = _get_normal_text()
		GameData.EXAMINE_MODE:
			cart = _get_examine_text()

	if game_over:
		message = YOU_WIN if player_win else YOU_LOSE
	elif NodeHub.ref_DataHub.sidebar_message != "":
		message = NodeHub.ref_DataHub.sidebar_message


	text = "\n".join([
		turn, doc, cash, phone_call,
		"", cart,
		"", message
	])


func _get_examine_text() -> String:
	var pc := NodeHub.ref_DataHub.pc
	var lcs := NodeHub.ref_DataHub.linked_cart_state

	return Cart.get_examine_text(pc, lcs)


func _get_normal_text() -> String:
	var pc := NodeHub.ref_DataHub.pc
	var lcs := NodeHub.ref_DataHub.linked_cart_state

	var first_item: String = Cart.get_first_item_text(pc, lcs)
	var last_slot: String = Cart.get_last_slot_text(pc, lcs)
	var extend: String = Cart.get_extend_text(lcs)
	var snippets: Array

	if first_item == "":
		snippets = [last_slot]
	elif last_slot == Cart.NO_LAST_SLOT:
		snippets = [first_item]
	else:
		snippets = [first_item, last_slot]

	if extend != "":
		snippets.push_back(extend)

	return "\n".join(snippets)

