class_name PcHitActor


static func handle_input(
        actor: Sprite2D, ref_PcAction: PcAction, ref_ActorAction: ActorAction,
        ref_RandomNumber: RandomNumber, ref_SignalHub: SignalHub,
        ref_Schedule: Schedule
        ) -> void:
    var actor_state: ActorState = ref_ActorAction.get_actor_state(actor)
    var player_win: bool
    var env_cooldown: int = _get_env_cooldown(ref_ActorAction)
    var first_item_tag: StringName = _get_first_item_tag(ref_PcAction)

    match SpriteState.get_sub_tag(actor):
        SubTag.SALARY:
            player_win = ref_PcAction.delivery < 1
            if _can_get_cash(ref_PcAction):
                _get_cash(ref_PcAction)
            elif player_win:
                pass
            else:
                return

        SubTag.GARAGE:
            if _can_use_garage(ref_PcAction):
                _use_garage(ref_PcAction)
            else:
                return

        SubTag.STATION:
            if _can_clean_cart(ref_PcAction) and _clean_cart(ref_PcAction):
                pass
            else:
                return

        SubTag.SERVANT:
            if _can_load_servant(ref_PcAction):
                _load_servant(actor, ref_PcAction)
            else:
                HandleRawFile.reduce_cooldown(
                        ref_ActorAction.raw_file_states, ref_RandomNumber
                        )
                HandleClerk.reduce_progress(
                        ref_ActorAction.clerk_states, ref_RandomNumber
                        )
                HandleServant.reset_idle_duration(actor_state)
                # Order matters. The Servant may be removed by _push_servant().
                _push_servant(actor, ref_PcAction)

        SubTag.OFFICER:
            if _remove_all_servant(ref_PcAction):
                pass
            elif HandleOfficer.can_receive_document(actor_state) \
                    and _can_unload_document(ref_PcAction):
                _unload_document(ref_PcAction)
                HandleRawFile.reset_cooldown(ref_ActorAction.raw_file_states)
                HandleOfficer.set_active(
                        ref_ActorAction.officer_states,
                        ref_ActorAction.officer_records, ref_RandomNumber
                        )
                GameProgress.update_challenge_level(ref_PcAction)
                GameProgress.update_phone(ref_PcAction, ref_RandomNumber)
                GameProgress.update_raw_file(ref_ActorAction, ref_RandomNumber)
                GameProgress.update_service(ref_ActorAction, ref_RandomNumber)
            else:
                return

        SubTag.ATLAS, SubTag.BOOK, SubTag.CUP, SubTag.ENCYCLOPEDIA:
            if _can_load_raw_file(actor, ref_PcAction, ref_ActorAction):
                _load_raw_file(actor, ref_PcAction)
                HandleRawFile.send_raw_file(
                        actor_state, env_cooldown, ref_RandomNumber
                        )
            elif _can_unload_servant(actor, ref_PcAction) \
                    and HandleRawFile.can_receive_servant(actor_state):
                _unload_servant(ref_PcAction)
                HandleRawFile.receive_servant(actor_state)
            else:
                return

        SubTag.CLERK:
            if _remove_all_servant(ref_PcAction):
                pass
            else:
                if _can_load_document(ref_PcAction) \
                        and HandleClerk.can_send_document(actor_state):
                    _load_document(ref_PcAction)
                    HandleClerk.send_document(actor_state)
                elif _can_unload_raw_file(ref_PcAction) \
                        and HandleClerk.can_receive_raw_file(
                                actor_state, first_item_tag
                                ):
                    HandleClerk.receive_raw_file(actor_state, first_item_tag)
                    _unload_raw_file(ref_PcAction)
                else:
                    return

        SubTag.PHONE:
            HandlePhone.answer_call(actor, ref_PcAction)

        SubTag.SHELF:
            HandleShelf.debug()
        _:
            return

    if player_win:
        ref_SignalHub.game_over.emit(true)
    else:
        ref_Schedule.start_next_turn()


static func _can_get_cash(ref_PcAction: PcAction) -> bool:
    return ref_PcAction.account > 0


static func _get_cash(ref_PcAction: PcAction) -> void:
    ref_PcAction.cash += ref_PcAction.account
    ref_PcAction.account = 0


static func _can_use_garage(ref_PcAction: PcAction) -> bool:
    if ref_PcAction.delivery < 1:
        return false
    elif ref_PcAction.cash < GameData.MIN_PAYMENT:
        return false
    return true


static func _use_garage(ref_PcAction: PcAction) -> void:
    Cart.add_cart(GameData.ADD_CART, ref_PcAction.linked_cart_state)
    ref_PcAction.cash -= GameData.PAYMENT_GARAGE


static func _can_clean_cart(ref_PcAction: PcAction) -> bool:
    return ref_PcAction.cash >= GameData.MIN_PAYMENT


static func _clean_cart(ref_PcAction: PcAction) -> bool:
    if Cart.clean_cart(ref_PcAction.pc, ref_PcAction.linked_cart_state):
        ref_PcAction.cash -= GameData.PAYMENT_CLEAN
        return true
    return false


static func _push_servant(actor: Sprite2D, ref_PcAction: PcAction) -> void:
    var actor_coord: Vector2i = ConvertCoord.get_coord(actor)
    var pc_coord: Vector2i = ref_PcAction.pc_coord
    var new_actor_coord: Vector2i
    var trap: Sprite2D
    var remove_actor: bool = true

    if Cart.count_cart(ref_PcAction.linked_cart_state) \
            < GameData.CART_LENGTH_SHORT:
        ref_PcAction.delay = 0
    else:
        ref_PcAction.delay = Cart.get_delay_duration(
                ref_PcAction.pc, ref_PcAction.linked_cart_state
                )

    new_actor_coord = ConvertCoord.get_mirror_coord(pc_coord, actor_coord)
    if _is_valid_coord(new_actor_coord):
        trap = SpriteState.get_trap_by_coord(new_actor_coord)
        if trap == null:
            remove_actor = false
            SpriteState.move_sprite(actor, new_actor_coord)
        else:
            SpriteFactory.remove_sprite(trap)
    if remove_actor:
        SpriteFactory.remove_sprite(actor)

    Cart.pull_cart(ref_PcAction.pc, actor_coord, ref_PcAction.linked_cart_state)


static func _is_valid_coord(coord: Vector2i) -> bool:
    return DungeonSize.is_in_dungeon(coord) \
            and (not SpriteState.has_building_at_coord(coord)) \
            and (not SpriteState.has_actor_at_coord(coord))


static func _can_unload_document(ref_PcAction: PcAction) -> bool:
    var cart_sprite: Sprite2D = Cart.get_first_item(
            ref_PcAction.pc, ref_PcAction.linked_cart_state
            )
    var cart_state: CartState

    if cart_sprite == null:
        return false

    cart_state = Cart.get_state(cart_sprite, ref_PcAction.linked_cart_state)
    return cart_state.item_tag == SubTag.DOCUMENT


static func _unload_document(ref_PcAction: PcAction) -> void:
    var cart_sprite: Sprite2D = Cart.get_first_item(
            ref_PcAction.pc, ref_PcAction.linked_cart_state
            )
    var cart_state: CartState = Cart.get_state(
            cart_sprite, ref_PcAction.linked_cart_state
            )

    cart_state.item_tag = SubTag.CART

    # PC can still unload document after reaching the final goal (deliver 5
    # documents), but has no profit or penalty in return.
    if ref_PcAction.delivery > 0:
        ref_PcAction.account += GameData.INCOME_DOCUMENT
        ref_PcAction.delivery -= 1

        ref_PcAction.missed_call += ref_PcAction.incoming_call
        if ref_PcAction.missed_call > GameData.MAX_MISSED_CALL:
            ref_PcAction.missed_call -= GameData.MAX_MISSED_CALL
            ref_PcAction.account -= GameData.MISSED_CALL_PENALTY


static func _can_load_raw_file(
        actor: Sprite2D, ref_PcAction: PcAction, ref_ActorAction: ActorAction
        ) -> bool:
    if not HandleRawFile.can_send_file(ref_ActorAction.get_actor_state(actor)):
        return false
    elif actor.is_in_group(SubTag.ENCYCLOPEDIA) \
            and (not _is_long_cart(ref_PcAction)):
        return false

    var cart: Sprite2D = Cart.get_last_slot(
            ref_PcAction.pc, ref_PcAction.linked_cart_state
            )
    return cart != null


static func _load_raw_file(actor: Sprite2D, ref_PcAction: PcAction) -> void:
    var cart: Sprite2D = Cart.get_last_slot(
            ref_PcAction.pc, ref_PcAction.linked_cart_state
            )
    var state: CartState
    var sub_tag: StringName

    state = Cart.get_state(cart, ref_PcAction.linked_cart_state)
    sub_tag = SpriteState.get_sub_tag(actor)
    state.item_tag = sub_tag


static func _can_load_document(ref_PcAction: PcAction) -> bool:
    return Cart.get_last_slot(
            ref_PcAction.pc, ref_PcAction.linked_cart_state
            ) != null


static func _load_document(ref_PcAction: PcAction) -> void:
    var sprite: Sprite2D =  Cart.get_last_slot(
            ref_PcAction.pc, ref_PcAction.linked_cart_state
            )
    var state: CartState = Cart.get_state(
            sprite, ref_PcAction.linked_cart_state
            )
    state.item_tag = SubTag.DOCUMENT


static func _can_unload_raw_file(ref_PcAction: PcAction) -> bool:
    var sprite: Sprite2D = Cart.get_first_item(
            ref_PcAction.pc, ref_PcAction.linked_cart_state
            )
    var state: CartState

    if sprite == null:
        return false

    state = Cart.get_state(sprite, ref_PcAction.linked_cart_state)
    return state.item_tag != SubTag.DOCUMENT


static func _unload_raw_file(ref_PcAction: PcAction) -> void:
    var sprite: Sprite2D = Cart.get_first_item(
            ref_PcAction.pc, ref_PcAction.linked_cart_state
            )
    var state: CartState = Cart.get_state(
            sprite, ref_PcAction.linked_cart_state
            )

    state.item_tag = SubTag.CART


static func _get_first_item_tag(ref_PcAction: PcAction) -> StringName:
    var sprite: Sprite2D = Cart.get_first_item(
            ref_PcAction.pc, ref_PcAction.linked_cart_state
            )
    var state: CartState

    if sprite == null:
        return SubTag.CART
    state = Cart.get_state(sprite, ref_PcAction.linked_cart_state)
    return state.item_tag


static func _can_load_servant(ref_PcAction: PcAction) -> bool:
    if Cart.count_cart(ref_PcAction.linked_cart_state) \
            < GameData.CART_LENGTH_SHORT:
        return false

    var sprite: Sprite2D = Cart.get_last_slot(
            ref_PcAction.pc, ref_PcAction.linked_cart_state
            )
    return sprite != null


static func _load_servant(actor: Sprite2D, ref_PcAction: PcAction) -> void:
    var sprite: Sprite2D = Cart.get_last_slot(ref_PcAction.pc,
            ref_PcAction.linked_cart_state)
    var state: CartState

    state = Cart.get_state(sprite, ref_PcAction.linked_cart_state)
    state.item_tag = SubTag.SERVANT

    SpriteFactory.remove_sprite(actor)
    Cart.pull_cart(
            ref_PcAction.pc, ConvertCoord.get_coord(actor),
            ref_PcAction.linked_cart_state
            )


static func _remove_all_servant(ref_PcAction: PcAction) -> bool:
    return Cart.remove_all_item(
            SubTag.SERVANT, ref_PcAction.pc, ref_PcAction.linked_cart_state
            )


static func _can_unload_servant(
        actor: Sprite2D, ref_PcAction: PcAction
        ) -> bool:
    var cart_sprite: Sprite2D = Cart.get_first_item(
            ref_PcAction.pc, ref_PcAction.linked_cart_state
            )
    var cart_state: CartState

    if cart_sprite == null:
        return false

    cart_state = Cart.get_state(cart_sprite, ref_PcAction.linked_cart_state)
    if cart_state.item_tag != SubTag.SERVANT:
        return false

    if actor.is_in_group(SubTag.ENCYCLOPEDIA):
        return _is_long_cart(ref_PcAction)
    return true


static func _unload_servant(ref_PcAction: PcAction) -> void:
        var cart_sprite: Sprite2D = Cart.get_first_item(
                ref_PcAction.pc, ref_PcAction.linked_cart_state
                )
        var cart_state: CartState = Cart.get_state(
                cart_sprite, ref_PcAction.linked_cart_state
                )

        cart_state.item_tag = SubTag.CART


static func _is_long_cart(ref_PcAction: PcAction) -> bool:
    return Cart.count_cart(ref_PcAction.linked_cart_state) \
            >= GameData.CART_LENGTH_LONG


static func _get_env_cooldown(ref_ActorAction: ActorAction) -> int:
    var servant_cooldown: int = HandleServant.get_servant_cooldown(
            ref_ActorAction.get_actor_states(SubTag.SERVANT)
            )
    # TODO: Count shelf_cooldown.
    var shelf_cooldown: int = 0
    return servant_cooldown + shelf_cooldown

