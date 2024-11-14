class_name PcAction
extends Node2D


signal ui_force_updated()


enum {
    NORMAL_MODE,
    EXAMINE_MODE
}


const VALID_ACTOR_TAGS: Array = [
    SubTag.CLERK,
    SubTag.OFFICER,

    SubTag.ATLAS,
    SubTag.BOOK,
    SubTag.CUP,
    SubTag.ENCYCLOPEDIA,

    SubTag.SALARY,
    SubTag.SERVANT,
    SubTag.STATION,
    SubTag.GARAGE,
]


var state_text: String:
    get:
        match _game_mode:
            NORMAL_MODE:
                return Cart.get_extend_text(_linked_cart_state)
            EXAMINE_MODE:
                return Cart.get_examine_text(pc, _linked_cart_state)
        return ""


var first_item_text: String:
    get:
        return Cart.get_first_item_text(pc, _linked_cart_state)


var cash: int = GameData.INCOME_INITIAL
var account: int = 0
var delivery: int = GameData.MAX_DELIVERY
var delay: int = 0


var pc: Sprite2D:
    get:
        return _pc


var pc_coord: Vector2i:
    get:
        return ConvertCoord.get_coord(pc)


var _pc: Sprite2D
var _game_mode: int = NORMAL_MODE

var _fov_map: Dictionary
var _shadow_cast_fov_data: ShadowCastFov.FovData

var _linked_cart_state := LinkedCartState.new()


func _ready() -> void:
    _fov_map = Map2D.init_map(PcFov.DEFAULT_FOV_FLAG)
    _shadow_cast_fov_data = ShadowCastFov.FovData.new(GameData.PC_SIGHT_RANGE)


func add_cart(new_cart_count: int) -> void:
    Cart.add_cart(new_cart_count, _linked_cart_state)


func clean_cart() -> bool:
    return Cart.clean_cart(pc, _linked_cart_state)


func pull_cart(coord: Vector2i) -> void:
    Cart.pull_cart(pc, coord, _linked_cart_state)


func count_cart() -> int:
    return Cart.count_cart(_linked_cart_state)


func get_first_item() -> Sprite2D:
    return Cart.get_first_item(pc, _linked_cart_state)


func get_state(cart: Sprite2D) -> CartState:
    return Cart.get_state(cart, _linked_cart_state)


func get_last_slot() -> Sprite2D:
    return Cart.get_last_slot(pc, _linked_cart_state)


func get_full_load_amount() -> int:
    return Cart.get_full_load_amount(pc, _linked_cart_state)


func count_item(item_tag: StringName) -> int:
    return Cart.count_item(item_tag, pc, _linked_cart_state)


func remove_all_item(item_tag: StringName) -> bool:
    return Cart.remove_all_item(item_tag, pc, _linked_cart_state)


func _on_SpriteFactory_sprite_created(tagged_sprites: Array) -> void:
    if pc != null:
        return

    for i: TaggedSprite in tagged_sprites:
        if i.sub_tag == SubTag.PC:
            _pc = i.sprite
            Cart.init_linked_carts(pc, _linked_cart_state)
            Cart.add_cart(GameData.MIN_CART, _linked_cart_state)
            return


func _on_Schedule_turn_started(sprite: Sprite2D) -> void:
    if not sprite.is_in_group(SubTag.PC):
        return

    NodeHub.ref_GameProgress.update_world(self)

    if Checkmate.is_game_over(self):
        NodeHub.ref_GameProgress.game_over.emit(false)
        return
    elif delay > 0:
        delay -= 1
        Cart.add_draft(_pc, _linked_cart_state, NodeHub.ref_RandomNumber)

        # The game loops without player's input. If call start_next_turn()
        # directly, there might be a stack overflow error when too many turns
        # are delayed (more than 10?).
        NodeHub.ref_Schedule.call_deferred("start_next_turn")

        # Another way is to wait until the next frame.
        # https://godotforums.org/d/35537-looking-for-a-way-to-signal-a-funtion-to-be-called-on-the-next-frame/7
        #
        # await get_tree().create_timer(0).timeout

        return
    PcFov.render_fov(pc, _fov_map, _shadow_cast_fov_data)


func _on_PlayerInput_action_pressed(input_tag: StringName) -> void:
    match _game_mode:
        NORMAL_MODE:
            match input_tag:
                InputTag.SWITCH_EXAMINE:
                    if Cart.enter_examine_mode(pc, _linked_cart_state):
                        _game_mode = EXAMINE_MODE
                        NodeHub.ref_ActorAction.switch_examine_mode(true)
                    else:
                        return
                InputTag.MOVE_LEFT:
                    _move(Vector2i.LEFT, _linked_cart_state)
                    return
                InputTag.MOVE_RIGHT:
                    _move(Vector2i.RIGHT, _linked_cart_state)
                    return
                InputTag.MOVE_UP:
                    _move(Vector2i.UP, _linked_cart_state)
                    return
                InputTag.MOVE_DOWN:
                    _move(Vector2i.DOWN, _linked_cart_state)
                    return
                InputTag.WIZARD_1, InputTag.WIZARD_2, \
                        InputTag.WIZARD_3, InputTag.WIZARD_4, \
                        InputTag.WIZARD_5, InputTag.WIZARD_6, \
                        InputTag.WIZARD_7, InputTag.WIZARD_8, \
                        InputTag.WIZARD_9, InputTag.WIZARD_0:
                    $WizardMode.handle_input(input_tag)
                _:
                    return
        EXAMINE_MODE:
            match input_tag:
                InputTag.SWITCH_EXAMINE, InputTag.EXIT_EXAMINE:
                    _game_mode = NORMAL_MODE
                    Cart.exit_examine_mode(pc, _linked_cart_state)
                    NodeHub.ref_ActorAction.switch_examine_mode(false)
                InputTag.MOVE_UP:
                    Cart.examine_first_cart(pc, _linked_cart_state)
                InputTag.MOVE_DOWN:
                    Cart.examine_last_cart(pc, _linked_cart_state)
                InputTag.MOVE_LEFT:
                    Cart.examine_previous_cart(pc, _linked_cart_state)
                InputTag.MOVE_RIGHT:
                    Cart.examine_next_cart(pc, _linked_cart_state)
                _:
                    return
    PcFov.render_fov(pc, _fov_map, _shadow_cast_fov_data)
    ui_force_updated.emit()


func _on_GameProgress_game_over(player_win: bool) -> void:
    PcFov.render_fov(pc, _fov_map, _shadow_cast_fov_data)
    if not player_win:
        VisualEffect.set_dark_color(pc)


func _move(direction: Vector2i, state: LinkedCartState) -> void:
    var coord: Vector2i = ConvertCoord.get_coord(pc) + direction
    var sprite: Sprite2D
    var sub_tag: StringName

    if not DungeonSize.is_in_dungeon(coord):
        return
    # Order matters in `The Life of a Government Clerk`. An actor may appear
    # above a building and therefore has a higher priority.
    elif SpriteState.has_actor_at_coord(coord):
        sprite = SpriteState.get_actor_by_coord(coord)
        sub_tag = SpriteState.get_sub_tag(sprite)
        if sub_tag in VALID_ACTOR_TAGS:
            PcHitActor.handle_input(sprite, self, NodeHub.ref_ActorAction,
                    NodeHub.ref_GameProgress, NodeHub.ref_Schedule)
        return
    elif SpriteState.has_building_at_coord(coord):
        sprite = SpriteState.get_building_by_coord(coord)
        if not sprite.is_in_group(SubTag.DOOR):
            return
    Cart.pull_cart(pc, coord, state)
    Cart.add_draft(pc, state, NodeHub.ref_RandomNumber)
    NodeHub.ref_Schedule.start_next_turn()
