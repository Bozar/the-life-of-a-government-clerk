class_name CartState


const ITEM_TO_VISUAL: Dictionary = {
    SubTag.CART: VisualTag.DEFAULT,
    SubTag.ATLAS: VisualTag.ACTIVE_1,
    SubTag.BOOK: VisualTag.ACTIVE_2,
    SubTag.CUP: VisualTag.ACTIVE_3,
    SubTag.DOCUMENT: VisualTag.ACTIVE_4,
}


var item_tag: StringName:
    get:
        return _item_tag
    set(value):
        if not value in ITEM_TO_VISUAL.keys():
            push_error("Invalid item tag: %s" % value)
            return
        _item_tag = value


var load_factor: int:
    get:
        return _load_factor
    set(value):
        _load_factor = min(max(value, GameData.MIN_LOAD_FACTOR),
                GameData.MAX_LOAD_FACTOR)


var visual_tag: StringName:
    get:
        if is_discarded:
            return VisualTag.PASSIVE_2
        elif load_factor >= GameData.MAX_LOAD_FACTOR:
            return VisualTag.PASSIVE_1
        return ITEM_TO_VISUAL.get(item_tag, VisualTag.DEFAULT)


var is_discarded: bool = false


var _item_tag: StringName = SubTag.CART
var _load_factor: int = GameData.MIN_LOAD_FACTOR
