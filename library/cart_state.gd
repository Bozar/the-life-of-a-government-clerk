class_name CartState


const ITEM_TO_VISUAL: Dictionary = {
    SubTag.CART: VisualTag.DEFAULT,

    SubTag.ATLAS: VisualTag.ACTIVE_1,
    SubTag.BOOK: VisualTag.ACTIVE_2,
    SubTag.CUP: VisualTag.ACTIVE_3,
    SubTag.DOCUMENT: VisualTag.ACTIVE_4,

    SubTag.FULL: VisualTag.PASSIVE_1,
    SubTag.DROPPED: VisualTag.PASSIVE_2,
}


var item_tag: StringName:
    get:
        return _item_tag
    set(value):
        if not value in ITEM_TO_VISUAL.keys():
            push_error("Invalid item tag: %s" % value)
            return
        _item_tag = value
        VisualEffect.switch_sprite(_sprite, ITEM_TO_VISUAL[_item_tag])


var load_factor: int:
    get:
        return _load_factor
    set(value):
        _load_factor = min(max(value, GameData.MIN_LOAD_FACTOR),
                GameData.MAX_LOAD_FACTOR)
        if _load_factor == GameData.MAX_LOAD_FACTOR:
            item_tag = SubTag.FULL


var is_full: bool:
    get:
        return load_factor >= GameData.MAX_LOAD_FACTOR


var is_dropped: bool:
    get:
        return _is_dropped
    set(value):
        if value:
            item_tag = SubTag.DROPPED
        _is_dropped = value


var _item_tag: StringName = SubTag.CART
var _load_factor: int = GameData.MIN_LOAD_FACTOR
var _is_dropped: bool = false
var _sprite: Sprite2D


func _init(sprite_: Sprite2D) -> void:
    _sprite = sprite_
