class_name StateLabel
extends CustomLabel


const YOU_WIN: String = "\n\nYou win.\n[Space]"
const YOU_LOSE: String = "\n\nYou lose.\n[Space]"


var game_over: bool = false
var player_win: bool = false


var _ref_PcAction: PcAction


func init_gui() -> void:
    _set_font(true)
    update_gui()


func update_gui() -> void:
    var sample: String = "$99|$10|+10\nA: 33%"
    var end_game: String = ""

    if game_over:
        end_game = YOU_WIN if player_win else YOU_LOSE

    text = "%s%s" % [sample, end_game]
