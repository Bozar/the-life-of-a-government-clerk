class_name Cart
extends Node2D


const EXTEND_TEMPLATE: String = "EXTEND: %s"
const EXAMINE_TEMPLATE: String = "?> %s: %s%%"
const FIRST_ITEM_TEMPLATE: String = "1> %s: %s%%"

const ITEM_TO_STRING: Dictionary = {
    SubTag.CART: "-",
    SubTag.ATLAS: "A",
    SubTag.BOOK: "B",
    SubTag.CUP: "C",
    SubTag.DOCUMENT: "D",
    SubTag.ENCYCLOPEDIA: "E",
}

# By game design, `DETACHED` and `FULL` only appears in Examine Mode.
const DETACHED: String = "?> DETACHED"
const FULL: String = "?> FULL"


static func init_linked_carts(head_cart: Sprite2D, state: LinkedCartState) \
        -> void:
    state.linked_carts = LinkedList.init_list(head_cart)


static func add_cart(new_cart_count: int, state: LinkedCartState) -> void:
    state.add_cart_counter += new_cart_count


static func count_cart(state: LinkedCartState) -> int:
    # There is exactly 1 PC and 0+ carts in `state.linked_carts`.
    return state.linked_carts.size() - 1


static func get_state(cart: Sprite2D, state: LinkedCartState) -> CartState:
    var cart_state: CartState = state.cart_states.get(cart.get_instance_id(),
            null)

    if cart_state == null:
        push_error("Cart state not found: %s" % cart.name)
    return cart_state


static func pull_cart(first_cart: Sprite2D, first_target_coord: Vector2i,
        state: LinkedCartState) -> void:
    var last_cart: Sprite2D
    var last_coord: Vector2i
    var remove: Sprite2D

    # Remove carts first, in order to pull fewer carts if possible.
    while state.save_detached_carts.size() > 0:
        remove = state.save_detached_carts.pop_back()
        _remove_cart(first_cart, remove, state)

    # Before moving the newer (perhaps shorter) cart line, record the position
    # of the last cart.
    last_cart = LinkedList.get_previous_object(first_cart, state.linked_carts)
    last_coord = ConvertCoord.get_coord(last_cart)

    # Move the cart line. Add a new cart to the recorded position if requried.
    _move_cart(first_cart, first_cart, first_target_coord, state)
    _add_cart_deferred(first_cart, last_coord, state)


static func get_first_item(pc: Sprite2D, state: LinkedCartState) -> Sprite2D:
    var cart: Sprite2D = pc
    var cart_state: CartState

    while true:
        # All carts have been examined.
        cart = LinkedList.get_next_object(cart, state.linked_carts)
        if cart == pc:
            return null
        # Find the first cart (starting from PC) that carries an item.
        cart_state = get_state(cart, state)
        if cart_state == null:
            continue
        elif cart_state.is_detached:
            continue
        elif cart_state.is_full:
            continue
        elif cart_state.item_tag == SubTag.CART:
            continue
        break
    return cart


static func get_last_slot(pc: Sprite2D, state: LinkedCartState) -> Sprite2D:
    var cart: Sprite2D = pc
    var cart_state: CartState

    while true:
        # All carts have been examined.
        cart = LinkedList.get_previous_object(cart, state.linked_carts)
        if cart == pc:
            return null
        # Find the last cart (starting from PC) that is empty.
        cart_state = get_state(cart, state)
        if cart_state == null:
            continue
        elif cart_state.is_detached:
            continue
        elif cart_state.is_full:
            continue
        elif cart_state.item_tag != SubTag.CART:
            continue
        break
    return cart


# By game design, return true if at least one cart is cleaned or detached, and
# therefore charge a small fee.
static func clean_cart(pc: Sprite2D, state: LinkedCartState) -> bool:
    var is_cleaned: bool = false
    var cart: Sprite2D = pc
    var cart_state: CartState

    # Note that the first cart is 0.
    for i in range(0, state.linked_carts.size()):
        cart = LinkedList.get_next_object(cart, state.linked_carts)
        # All carts have been examined.
        if cart == pc:
            break
        cart_state = get_state(cart, state)
        # This should not happen.
        if cart_state == null:
            continue
        # By game design, the first few carts can be cleaned, but not detached.
        elif i < GameData.MIN_CART:
            # This should not happen.
            if cart_state.is_detached:
                continue
            elif cart_state.load_factor > GameData.MIN_LOAD_FACTOR:
                cart_state.load_factor = GameData.MIN_LOAD_FACTOR
                is_cleaned = true
        # By game design, trailing carts can be detached, but not cleaned.
        else:
            # This could happen.
            if cart_state.is_detached:
                continue
            elif cart_state.is_full:
                cart_state.is_detached = true
                is_cleaned = true
                state.save_detached_carts.push_back(cart)
    return is_cleaned


static func enter_examine_mode(pc: Sprite2D, state: LinkedCartState) -> bool:
    # There should be at least two sprites (PC and cart) to enable examine mode.
    if state.linked_carts.size() < 2:
        return false

    var target_cart: Sprite2D = LinkedList.get_next_object(pc,
            state.linked_carts)
    var target_coord: Vector2i = ConvertCoord.get_coord(target_cart)

    state.save_pc_coord = ConvertCoord.get_coord(pc)
    # By game design, PC can move over cart sprites.
    SpriteState.move_sprite(pc, target_coord, pc.z_index + 1)
    VisualEffect.switch_sprite(pc, VisualTag.PASSIVE)
    return true


static func exit_examine_mode(pc: Sprite2D, has_stick: bool,
        state: LinkedCartState) -> void:
    var new_tag: StringName = VisualTag.ACTIVE if has_stick else \
            VisualTag.DEFAULT

    SpriteState.move_sprite(pc, state.save_pc_coord, pc.z_index - 1)
    VisualEffect.switch_sprite(pc, new_tag)


static func examine_first_cart(pc: Sprite2D, state: LinkedCartState) -> void:
    var cart: Sprite2D = LinkedList.get_next_object(pc, state.linked_carts)
    var coord: Vector2i = ConvertCoord.get_coord(cart)

    SpriteState.move_sprite(pc, coord)


static func examine_last_cart(pc: Sprite2D, state: LinkedCartState) -> void:
    var cart: Sprite2D = LinkedList.get_previous_object(pc, state.linked_carts)
    var coord: Vector2i = ConvertCoord.get_coord(cart)

    SpriteState.move_sprite(pc, coord)


static func examine_next_cart(pc: Sprite2D, state: LinkedCartState) -> void:
    var pc_coord: Vector2i = ConvertCoord.get_coord(pc)
    var current_cart: Sprite2D = SpriteState.get_actor_by_coord(pc_coord)
    var find_cart: Sprite2D
    var find_coord: Vector2i

    find_cart = LinkedList.get_next_object(current_cart, state.linked_carts)
    if find_cart == pc:
        find_cart = LinkedList.get_next_object(find_cart, state.linked_carts)
    find_coord = ConvertCoord.get_coord(find_cart)
    SpriteState.move_sprite(pc, find_coord)


static func examine_previous_cart(pc: Sprite2D, state: LinkedCartState) -> void:
    var pc_coord: Vector2i = ConvertCoord.get_coord(pc)
    var current_cart: Sprite2D = SpriteState.get_actor_by_coord(pc_coord)
    var find_cart: Sprite2D
    var find_coord: Vector2i

    find_cart = LinkedList.get_previous_object(current_cart, state.linked_carts)
    if find_cart == pc:
        find_cart = LinkedList.get_previous_object(find_cart,
                state.linked_carts)
    find_coord = ConvertCoord.get_coord(find_cart)
    SpriteState.move_sprite(pc, find_coord)


static func get_extend_text(state: LinkedCartState) -> String:
    if state.add_cart_counter > 0:
        return EXTEND_TEMPLATE % state.add_cart_counter
    return ""


# This function should only be called in examine mode, which implies that there
# is a cart sprite under PC.
static func get_examine_text(pc: Sprite2D, state: LinkedCartState) -> String:
    return _get_cart_state_text(ConvertCoord.get_coord(pc), EXAMINE_TEMPLATE,
            state)


static func get_first_item_text(pc: Sprite2D, state: LinkedCartState) -> String:
    var cart: Sprite2D = get_first_item(pc, state)
    var coord: Vector2i

    if cart == null:
        return ""
    coord = ConvertCoord.get_coord(cart)
    return _get_cart_state_text(coord, FIRST_ITEM_TEMPLATE, state)


static func _get_cart_state_text(coord: Vector2i, text_template: String,
        state: LinkedCartState) -> String:
    var cart: Sprite2D = SpriteState.get_actor_by_coord(coord)
    var cart_state: CartState = get_state(cart, state)

    if cart_state == null:
        return ""
    elif cart_state.is_detached:
        return DETACHED
    elif cart_state.is_full:
        return FULL
    return text_template % [
        ITEM_TO_STRING.get(cart_state.item_tag, "-"),
        cart_state.load_factor,
    ]


# Move carts from the first one (inclusive) to the last one (exclusive).
static func _move_cart(first_cart: Sprite2D, last_cart: Sprite2D,
        first_coord: Vector2i, state: LinkedCartState) -> void:
    var next_cart: Sprite2D = first_cart
    var target_coord: Vector2i = first_coord
    var save_coord: Vector2i

    while true:
            # 1/2: Update coord for the next cart.
            save_coord = ConvertCoord.get_coord(next_cart)
            # Move current cart.
            SpriteState.move_sprite(next_cart, target_coord)
            # 2/2: Update coord for the next cart.
            next_cart = LinkedList.get_next_object(next_cart,
                    state.linked_carts)
            target_coord = save_coord
            # End loop when reaching the last cart.
            if next_cart == last_cart:
                break


static func _add_cart_deferred(first_cart: Sprite2D, new_coord: Vector2i,
        state: LinkedCartState) -> void:
    if state.add_cart_counter < 1:
        return

    var new_cart: Sprite2D = SpriteFactory.create_actor(SubTag.CART, new_coord,
            true).sprite

    LinkedList.insert_object(new_cart, first_cart, state.linked_carts)
    state.cart_states[new_cart.get_instance_id()] = CartState.new(new_cart)
    state.add_cart_counter -= 1


static func _remove_cart(first_cart: Sprite2D, remove_cart: Sprite2D,
        state: LinkedCartState) -> void:
    var remove_id: int = remove_cart.get_instance_id()
    var remove_coord: Vector2i = ConvertCoord.get_coord(remove_cart)
    var next_cart: Sprite2D = LinkedList.get_next_object(remove_cart,
            state.linked_carts)

    LinkedList.remove_object(remove_cart, state.linked_carts)
    state.cart_states.erase(remove_id)
    SpriteFactory.remove_sprite(remove_cart)

    # Note that `state.linked_carts` is cyclic.
    # first_cart - ... - remove_cart - next_cart - ... - [first_cart]
    if next_cart != first_cart:
        _move_cart(next_cart, first_cart, remove_coord, state)
