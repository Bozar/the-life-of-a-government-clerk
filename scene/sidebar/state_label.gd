class_name StateLabel
extends CustomLabel


const YOU_WIN: String = "You win.\n[Space]"
const YOU_LOSE: String = "You lose.\n[Space]"


var game_over: bool = false
var player_win: bool = false


var _ref_PcAction: PcAction


func init_gui() -> void:
    _set_font(true)
    update_gui()


func update_gui() -> void:
    var progress: String = "$99|$10|+10"
    var first_item: String = _ref_PcAction.first_item_text
    var state: String = _ref_PcAction.state_text
    var end_game: String = ""

    if game_over:
        end_game = YOU_WIN if player_win else YOU_LOSE
    text = "%s\n%s\n%s\n\n%s" % [progress, first_item, state, end_game]
