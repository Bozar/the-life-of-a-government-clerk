class_name PcAction
extends Node2D


enum {
    NORMAL_MODE,
    EXAMINE_MODE,
}


# `VALID_ACTOR_TAGS` seems to be obseleted?
# const VALID_ACTOR_TAGS: Array = [
#     SubTag.CLERK,
#     SubTag.OFFICER,

#     SubTag.ATLAS,
#     SubTag.BOOK,
#     SubTag.CUP,
#     SubTag.ENCYCLOPEDIA,

#     SubTag.SALARY,
#     SubTag.SERVANT,
#     SubTag.STATION,
#     SubTag.GARAGE,
#     SubTag.PHONE,
# ]

const VALID_TRAP_TAGS: Array = [
    SubTag.TRASH,
]


var cash: int = GameData.INCOME_INITIAL
var account: int = 0

var missed_call: int = 0

var max_delivery: int = GameData.CHALLENGES_PER_DELIVERY.size()
var delivery: int = max_delivery


var delay: int = 0


var pc: Sprite2D:
    get:
        return _pc


var pc_coord: Vector2i:
    get:
        return ConvertCoord.get_coord(pc)


var game_mode: int:
    get:
        return _game_mode


var linked_cart_state: LinkedCartState:
    get:
        return _linked_cart_state


var incoming_call: int:
    get:
        return _incoming_call


var _linked_cart_state := LinkedCartState.new()
var _incoming_call: int = 0


var _pc: Sprite2D
var _game_mode: int = NORMAL_MODE
var _progress_state := ProgressState.new()
var _is_first_turn: bool = true

var _fov_map: Dictionary = Map2D.init_map(PcFov.DEFAULT_FOV_FLAG)
var _shadow_cast_fov_data: ShadowCastFov.FovData = ShadowCastFov.FovData.new(
        GameData.PC_SIGHT_RANGE)


func _on_SignalHub_sprite_created(tagged_sprites: Array) -> void:
    for i: TaggedSprite in tagged_sprites:
        match i.sub_tag:
            SubTag.PC:
                if pc != null:
                    continue
                _pc = i.sprite
                Cart.init_linked_carts(pc, linked_cart_state)
                Cart.add_cart(GameData.MIN_CART, linked_cart_state)
            SubTag.PHONE:
                _incoming_call += 1


func _on_SignalHub_sprite_removed(sprites: Array) -> void:
    for i: Sprite2D in sprites:
        if i.is_in_group(SubTag.PHONE):
            _incoming_call -= 1


func _on_SignalHub_turn_started(sprite: Sprite2D) -> void:
    if not sprite.is_in_group(SubTag.PC):
        return

    # Wait 1 frame when the very first turn starts, so that sprites from the
    # previous scene are properly removed.
    if _is_first_turn:
        await get_tree().create_timer(0).timeout
        _is_first_turn = false

    GameProgress.update_world(
            _progress_state, self, NodeHub.ref_ActorAction,
            NodeHub.ref_RandomNumber
            )

    if Checkmate.is_game_over(self):
        NodeHub.ref_SignalHub.game_over.emit(false)
        return
    elif delay > 0:
        delay -= 1
        Cart.add_trash(pc, linked_cart_state, NodeHub.ref_RandomNumber)

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


func _on_SignalHub_action_pressed(input_tag: StringName) -> void:
    match game_mode:
        NORMAL_MODE:
            if _handle_normal_input(input_tag):
                return
        EXAMINE_MODE:
            if _handle_examine_input(input_tag):
                return
    PcFov.render_fov(pc, _fov_map, _shadow_cast_fov_data)
    NodeHub.ref_SignalHub.ui_force_updated.emit()


func _on_SignalHub_game_over(player_win: bool) -> void:
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
        # `VALID_ACTOR_TAGS` seems to be obseleted?
        # if sub_tag in VALID_ACTOR_TAGS:
        PcHitActor.handle_input(
                sprite, self, NodeHub.ref_ActorAction,
                NodeHub.ref_RandomNumber, NodeHub.ref_SignalHub,
                NodeHub.ref_Schedule
                )
        return
    elif SpriteState.has_trap_at_coord(coord):
        sprite = SpriteState.get_trap_by_coord(coord)
        sub_tag = SpriteState.get_sub_tag(sprite)
        if sub_tag in VALID_TRAP_TAGS:
            PcHitTrap.handle_input(
                    sprite, self, NodeHub.ref_RandomNumber, NodeHub.ref_Schedule
                    )
        return
    elif SpriteState.has_building_at_coord(coord):
        sprite = SpriteState.get_building_by_coord(coord)
        if not sprite.is_in_group(SubTag.DOOR):
            return
    Cart.pull_cart(pc, coord, state)
    Cart.add_trash(pc, state, NodeHub.ref_RandomNumber)
    NodeHub.ref_Schedule.start_next_turn()


func _handle_normal_input(input_tag: StringName) -> bool:
    match input_tag:
        InputTag.SWITCH_EXAMINE:
            if Cart.enter_examine_mode(pc, linked_cart_state):
                _game_mode = EXAMINE_MODE
                PcSwitchMode.examine_mode(true, NodeHub.ref_ActorAction)
                return false
        InputTag.MOVE_LEFT:
            _move(Vector2i.LEFT, linked_cart_state)
        InputTag.MOVE_RIGHT:
            _move(Vector2i.RIGHT, linked_cart_state)
        InputTag.MOVE_UP:
            _move(Vector2i.UP, linked_cart_state)
        InputTag.MOVE_DOWN:
            _move(Vector2i.DOWN, linked_cart_state)
        InputTag.WIZARD_1, InputTag.WIZARD_2, \
                InputTag.WIZARD_3, InputTag.WIZARD_4, \
                InputTag.WIZARD_5, InputTag.WIZARD_6, \
                InputTag.WIZARD_7, InputTag.WIZARD_8, \
                InputTag.WIZARD_9, InputTag.WIZARD_0:
            WizardMode.handle_input(input_tag)
        _:
            return true
    return true


func _handle_examine_input(input_tag: StringName) -> bool:
    match input_tag:
        InputTag.SWITCH_EXAMINE, InputTag.EXIT_EXAMINE:
            _game_mode = NORMAL_MODE
            Cart.exit_examine_mode(pc, linked_cart_state)
            PcSwitchMode.examine_mode(false, NodeHub.ref_ActorAction)
        InputTag.MOVE_UP:
            Cart.examine_first_cart(pc, linked_cart_state)
        InputTag.MOVE_DOWN:
            Cart.examine_last_cart(pc, linked_cart_state)
        InputTag.MOVE_LEFT:
            Cart.examine_previous_cart(pc, linked_cart_state)
        InputTag.MOVE_RIGHT, InputTag.EXAMINE_NEXT_CART:
            Cart.examine_next_cart(pc, linked_cart_state)
        _:
            return true
    return false
