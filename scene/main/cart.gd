class_name Cart
extends Node2D


var _linked_carts: Dictionary
var _cart_states: Dictionary = {}

var _add_cart_counter: int = 0


func init_linked_carts(head_cart: Sprite2D) -> void:
    _linked_carts = LinkedList.init_list(head_cart)


func add_cart(new_cart_count: int) -> void:
    _add_cart_counter += new_cart_count


func pull_cart(head_cart: Sprite2D, head_cart_target_coord: Vector2i) -> void:
    var next_cart: Sprite2D = head_cart
    var target_coord: Vector2i = head_cart_target_coord
    var save_coord: Vector2i
    var new_cart: Sprite2D

    while true:
        # Move current cart.
        save_coord = ConvertCoord.get_coord(next_cart)
        SpriteState.move_sprite(next_cart, target_coord)
        # Update coord for the next cart.
        next_cart = LinkedList.get_next_object(next_cart, _linked_carts)
        target_coord = save_coord
        if next_cart == head_cart:
            break

    if _add_cart_counter > 0:
        new_cart = SpriteFactory.create_actor(SubTag.CART, target_coord,
                true).sprite
        LinkedList.insert_object(new_cart, head_cart, _linked_carts)
        _cart_states[new_cart.get_instance_id()] = CartState.new()
        _add_cart_counter -= 1
