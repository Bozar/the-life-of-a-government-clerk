class_name StateLabel
extends CustomLabel


const TURN: String = "Turn: %1d"
const DOC: String = "Doc: %2d"
const CASH: String = "Cash: %1d-%1d"
const CALL: String = "Call: %1d-%1d"

const YOU_WIN: String = "You win.\n[Space]"
const YOU_LOSE: String = "You lose.\n[Space]"


var game_over: bool = false
var player_win: bool = false


var _turn_counter: int = GameData.MIN_TURN_COUNTER - 1


func init_gui() -> void:
    _set_font(true)
    update_gui()


func update_gui() -> void:
    var turn: String = TURN % _turn_counter
    var doc: String = DOC % NodeHub.ref_PcAction.delivery
    var cash: String = CASH % [
        NodeHub.ref_PcAction.cash, NodeHub.ref_PcAction.account,
    ]
    var phone_call: String = CALL % [
        NodeHub.ref_PcAction.incoming_call, NodeHub.ref_PcAction.missed_call,
    ]
    var first_item: String = Cart.get_first_item_text(
            NodeHub.ref_PcAction.pc, NodeHub.ref_PcAction.linked_cart_state
            )
    var last_slot: String = Cart.get_last_slot_text(
            NodeHub.ref_PcAction.pc, NodeHub.ref_PcAction.linked_cart_state
            )
    var cart: String = last_slot if (first_item == "") else first_item
    var state: String = _get_state_text()
    var end_game: String

    if game_over:
        end_game = YOU_WIN if player_win else YOU_LOSE

    text = "\n".join([
        turn, doc, cash, phone_call, "", cart, state, "", end_game
    ])


func add_turn_counter() -> void:
    _turn_counter += 1
    if _turn_counter > GameData.MAX_TURN_COUNTER:
        _turn_counter = GameData.MIN_TURN_COUNTER
    else:
        _turn_counter = max(_turn_counter, GameData.MIN_TURN_COUNTER)


func _get_state_text() -> String:
    match NodeHub.ref_PcAction.game_mode:
        NodeHub.ref_PcAction.NORMAL_MODE:
            return Cart.get_extend_text(NodeHub.ref_PcAction.linked_cart_state)
        NodeHub.ref_PcAction.EXAMINE_MODE:
            return Cart.get_examine_text(
                    NodeHub.ref_PcAction.pc,
                    NodeHub.ref_PcAction.linked_cart_state
                    )
    return ""

