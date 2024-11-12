class_name CartState


const ITEM_TO_VISUAL: Dictionary = {
    SubTag.CART: VisualTag.DEFAULT,

    SubTag.ATLAS: VisualTag.ACTIVE_1,
    SubTag.BOOK: VisualTag.ACTIVE_2,
    SubTag.CUP: VisualTag.ACTIVE_3,
    SubTag.DOCUMENT: VisualTag.ACTIVE_4,
    SubTag.ENCYCLOPEDIA: VisualTag.ACTIVE_5,
    SubTag.SERVANT: VisualTag.ACTIVE_6,

    SubTag.FULL: VisualTag.PASSIVE_1,
    SubTag.DETACHED: VisualTag.PASSIVE_2,
}


var item_tag: StringName:
    get:
        return _item_tag
    set(value):
        if not value in ITEM_TO_VISUAL.keys():
            push_error("Invalid item tag: %s" % value)
            return
        # A DETACHED cart cannot be changed further.
        elif _item_tag == SubTag.DETACHED:
            return
        _item_tag = value
        VisualEffect.switch_sprite(_sprite, ITEM_TO_VISUAL[_item_tag])


var load_amount: int:
    get:
        return _load_amount
    set(value):
        # A DETACHED cart cannot be changed further.
        if _is_detached:
            return
        _load_amount = min(max(value, GameData.MIN_LOAD),
                GameData.MAX_LOAD_PER_CART)
        # Change cart sprite when the cart is fully loaded.
        if _load_amount == GameData.MAX_LOAD_PER_CART:
            item_tag = SubTag.FULL
        # Change cart sprite when a fully loaded cart is cleaned.
        elif _load_amount == GameData.MIN_LOAD:
            if _item_tag == SubTag.FULL:
                item_tag = SubTag.CART


var is_full: bool:
    get:
        return load_amount >= GameData.MAX_LOAD_PER_CART


var is_detached: bool:
    get:
        return _is_detached
    set(value):
        # Change cart sprite when the cart is detached.
        if value:
            item_tag = SubTag.DETACHED
        _is_detached = value


var _item_tag: StringName = SubTag.CART
var _load_amount: int = GameData.MIN_LOAD
var _is_detached: bool = false
var _sprite: Sprite2D


func _init(sprite_: Sprite2D) -> void:
    _sprite = sprite_
