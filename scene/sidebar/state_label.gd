class_name StateLabel
extends CustomLabel


const TURN: String = "Turn: %1d"
const DOC: String = "Doc: %2d"
const CASH: String = "Cash: %1d-%1d"
const CALL: String = "Call: %1d-%1d"
const CART: String = "%s\n%s"
const CHALLENGE: String = "%s-%s-%s-%s-%s"

const YOU_WIN: String = "You win.\n%s\n[Enter]"
const YOU_LOSE: String = "You lose.\n[Enter]\n"


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
		GameModeTag.NORMAL:
			cart = _get_normal_text()
			message = _get_message_text()
		GameModeTag.EXAMINE:
			cart = _get_examine_text()
		GameModeTag.HELP:
			cart = HelpMode.get_sidebar_text()

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


func _get_message_text() -> String:
	var message: String

	if game_over:
		if player_win:
			message = YOU_WIN % _get_challenge_text()
		else:
			message = YOU_LOSE
	elif NodeHub.ref_DataHub.sidebar_message != "":
		message = NodeHub.ref_DataHub.sidebar_message
	return message


func _get_challenge_text() -> String:
	var states: Array

	for i: int in ChallengeTag.ALL_CHALLENGES:
		if NodeHub.ref_DataHub.is_challenge_state(
				i, ChallengeTag.FINISHED
		):
			states.push_back(ChallengeTag.NAME_TO_STRING[i])
		else:
			states.push_back(ChallengeTag.NO_NAME)
	return CHALLENGE % states

