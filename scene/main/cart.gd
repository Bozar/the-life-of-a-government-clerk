class_name Cart
extends Node2D


var _linked_carts: Dictionary
var _cart_states: Dictionary = {}

var _add_cart_counter: int = 0


func init_linked_carts(head_cart: Sprite2D) -> void:
    _linked_carts = LinkedList.init_list(head_cart)


func add_cart(new_cart_count: int) -> void:
    _add_cart_counter += new_cart_count


func pull_cart(first_cart: Sprite2D, first_target_coord: Vector2i) -> void:
    var last_cart: Sprite2D = LinkedList.get_previous_object(first_cart,
            _linked_carts)
    var last_coord: Vector2i = ConvertCoord.get_coord(last_cart)

    _move_cart(first_cart, first_cart, first_target_coord)
    _add_cart_deferred(first_cart, last_coord)


# Move carts from the first one (inclusive) to the last one (exclusive).
func _move_cart(first_cart: Sprite2D, last_cart: Sprite2D,
        first_coord: Vector2i) -> void:
    var next_cart: Sprite2D = first_cart
    var target_coord: Vector2i = first_coord
    var save_coord: Vector2i

    while true:
            # 1/2: Update coord for the next cart.
            save_coord = ConvertCoord.get_coord(next_cart)
            # Move current cart.
            SpriteState.move_sprite(next_cart, target_coord)
            # 2/2: Update coord for the next cart.
            next_cart = LinkedList.get_next_object(next_cart, _linked_carts)
            target_coord = save_coord
            # End loop when reaching the last cart.
            if next_cart == last_cart:
                break


func _add_cart_deferred(first_cart: Sprite2D, new_coord: Vector2i) -> void:
    if _add_cart_counter < 1:
        return

    var new_cart: Sprite2D = SpriteFactory.create_actor(SubTag.CART, new_coord,
            true).sprite

    LinkedList.insert_object(new_cart, first_cart, _linked_carts)
    _cart_states[new_cart.get_instance_id()] = CartState.new()
    _add_cart_counter -= 1


func _remove_cart(first_cart: Sprite2D, remove_cart: Sprite2D) -> void:
    var remove_id: int = remove_cart.get_instance_id()
    var remove_coord: Vector2i = ConvertCoord.get_coord(remove_cart)
    var next_cart: Sprite2D = LinkedList.get_next_object(remove_cart,
            _linked_carts)

    LinkedList.remove_object(remove_cart, _linked_carts)
    _cart_states.erase(remove_id)
    SpriteFactory.remove_sprite(remove_cart)

    # Note that `_linked_carts` is cyclic.
    # first_cart - ... - remove_cart - next_cart - ... - [first_cart]
    if next_cart != first_cart:
        _move_cart(next_cart, first_cart, remove_coord)
