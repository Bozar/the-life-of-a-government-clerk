class_name PcAction
extends Node2D


signal ui_force_updated()


enum {
    NORMAL_MODE,
    EXAMINE_MODE
}


var state_text: String:
    get:
        match _game_mode:
            NORMAL_MODE:
                return _ref_Cart.get_extend_text()
            EXAMINE_MODE:
                return _ref_Cart.get_examine_text(_pc)
        return ""


var first_item_text: String:
    get:
        return _ref_Cart.get_first_item_text(_pc)


var _ref_ActorAction: ActorAction
var _ref_GameProgress: GameProgress

@onready var _ref_PcFov: PcFov = $PcFov
@onready var _ref_WizardMode: WizardMode = $WizardMode
@onready var _ref_Cart: Cart = $Cart
@onready var _ref_Checkmate: Checkmate = $Checkmate


var _pc: Sprite2D
var _game_mode: int = NORMAL_MODE


func _on_SpriteFactory_sprite_created(tagged_sprites: Array) -> void:
    if _pc != null:
        return

    for i: TaggedSprite in tagged_sprites:
        if i.sub_tag == SubTag.PC:
            _pc = i.sprite
            _ref_Cart.init_linked_carts(_pc)
            return


func _on_Schedule_turn_started(sprite: Sprite2D) -> void:
    if not sprite.is_in_group(SubTag.PC):
        return
    elif _ref_Checkmate.is_game_over(ConvertCoord.get_coord(_pc)):
        _ref_GameProgress.game_over.emit(false)
        return
    _ref_PcFov.render_fov(_pc)


func _on_PlayerInput_action_pressed(input_tag: StringName) -> void:
    match _game_mode:
        NORMAL_MODE:
            match input_tag:
                InputTag.SWITCH_EXAMINE:
                    if _ref_Cart.enter_examine_mode(_pc):
                        _game_mode = EXAMINE_MODE
                    else:
                        return
                InputTag.MOVE_LEFT:
                    _move(_pc, Vector2i.LEFT)
                    return
                InputTag.MOVE_RIGHT:
                    _move(_pc, Vector2i.RIGHT)
                    return
                InputTag.MOVE_UP:
                    _move(_pc, Vector2i.UP)
                    return
                InputTag.MOVE_DOWN:
                    _move(_pc, Vector2i.DOWN)
                    return
                InputTag.WIZARD_1, InputTag.WIZARD_2, InputTag.WIZARD_3:
                    _ref_WizardMode.handle_input(input_tag)
                _:
                    return
        EXAMINE_MODE:
            match input_tag:
                InputTag.SWITCH_EXAMINE, InputTag.EXIT_EXAMINE:
                    _game_mode = NORMAL_MODE
                    _ref_Cart.exit_examine_mode(_pc)
                InputTag.MOVE_UP:
                    _ref_Cart.examine_first_cart(_pc)
                InputTag.MOVE_DOWN:
                    _ref_Cart.examine_last_cart(_pc)
                InputTag.MOVE_LEFT:
                    _ref_Cart.examine_previous_cart(_pc)
                InputTag.MOVE_RIGHT:
                    _ref_Cart.examine_next_cart(_pc)
                _:
                    return
    _ref_PcFov.render_fov(_pc)
    ui_force_updated.emit()


func _on_GameProgress_game_over(player_win: bool) -> void:
    _ref_PcFov.render_fov(_pc)
    if not player_win:
        VisualEffect.set_dark_color(_pc)


func _move(pc: Sprite2D, direction: Vector2i) -> void:
    var coord: Vector2i = ConvertCoord.get_coord(_pc) + direction

    if not DungeonSize.is_in_dungeon(coord):
        return
    elif SpriteState.has_building_at_coord(coord):
        return
    elif SpriteState.has_actor_at_coord(coord):
        return
    _ref_Cart.pull_cart(pc, coord)
    ScheduleHelper.start_next_turn()
