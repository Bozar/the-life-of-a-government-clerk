class_name Sidebar
extends CustomMarginContainer


@onready var _ref_FootnoteLabel: FootnoteLabel = $SidebarVBox/FootnoteLabel
@onready var _ref_StateLabel: StateLabel = $SidebarVBox/StateLabel


func init_gui() -> void:
    _ref_FootnoteLabel.init_gui()
    _ref_StateLabel.init_gui()


func update_gui() -> void:
    _ref_StateLabel.update_gui()


func _on_SignalHub_ui_updated(sprite: Sprite2D) -> void:
    if not sprite.is_in_group(SubTag.PC):
        return
    update_gui()


func _on_SignalHub_game_over(player_win: bool) -> void:
    _ref_StateLabel.game_over = true
    _ref_StateLabel.player_win = player_win
    _ref_StateLabel.update_gui()


func _on_SignalHub_ui_force_updated() -> void:
    update_gui()


func _on_SignalHub_action_pressed(input_tag: StringName) -> void:
    match input_tag:
        InputTag.CLOSE_MENU:
            visible = true
        InputTag.OPEN_DEBUG_MENU, InputTag.OPEN_HELP_MENU:
            visible = false

