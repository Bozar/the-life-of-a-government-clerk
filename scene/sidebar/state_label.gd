class_name StateLabel
extends CustomLabel


const PROGRESS_TEMPLATE: String = "Turn: %s\nDocu: %s\nCash: %s-%s"

const YOU_WIN: String = "You win.\n[Space]"
const YOU_LOSE: String = "You lose.\n[Space]"


var game_over: bool = false
var player_win: bool = false


var _turn_counter: int = GameData.MIN_TURN_COUNTER - 1


func init_gui() -> void:
    _set_font(true)
    update_gui()


func update_gui() -> void:
    var progress: String = PROGRESS_TEMPLATE % [
        _turn_counter, NodeHub.ref_PcAction.delivery,
        NodeHub.ref_PcAction.cash, NodeHub.ref_PcAction.account,
    ]
    var first_item: String = Cart.get_first_item_text(
            NodeHub.ref_PcAction.pc, NodeHub.ref_PcAction.linked_cart_state
            )
    var state: String = _get_state_text()
    var end_game: String = ""

    if game_over:
        end_game = YOU_WIN if player_win else YOU_LOSE
    text = "%s\n\n%s\n%s\n%s" % [
        progress, first_item, state, end_game
    ]


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
