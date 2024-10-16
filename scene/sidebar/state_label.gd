class_name StateLabel
extends CustomLabel


const PROGRESS: String = "+%s.%s|$%s.%s"

const YOU_WIN: String = "You win.\n[Space]"
const YOU_LOSE: String = "You lose.\n[Space]"


var game_over: bool = false
var player_win: bool = false


var _ref_PcAction: PcAction


var _turn_counter: int = GameData.MIN_TURN_COUNTER - 1


func init_gui() -> void:
    _set_font(true)
    update_gui()


func update_gui() -> void:
    var progress: String = PROGRESS % [
        _turn_counter, _ref_PcAction.delivery,
        _ref_PcAction.cash, _ref_PcAction.account,
    ]
    var first_item: String = _ref_PcAction.first_item_text
    var state: String = _ref_PcAction.state_text
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
