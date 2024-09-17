class_name SpriteScene


const SPRITE_SCENES: Dictionary = {
    # Ground
    SubTag.DUNGEON_FLOOR: preload("res://sprite/dungeon_floor.tscn"),
    SubTag.INTERNAL_FLOOR: preload("res://sprite/internal_floor.tscn"),


    # Trap


    # Building
    SubTag.WALL: preload("res://sprite/wall.tscn"),
    SubTag.DOOR: preload("res://sprite/door.tscn"),
    SubTag.DESK: preload("res://sprite/desk.tscn"),


    # Actor
    SubTag.PC: preload("res://sprite/pc.tscn"),
    SubTag.CART: preload("res://sprite/cart.tscn"),
    SubTag.CLERK: preload("res://sprite/clerk.tscn"),
    SubTag.OFFICER: preload("res://sprite/officer.tscn"),

    SubTag.ATLAS: preload("res://sprite/atlas.tscn"),
    SubTag.BOOK: preload("res://sprite/book.tscn"),
    SubTag.CUP: preload("res://sprite/cup.tscn"),
    SubTag.ENCYCLOPEDIA: preload("res://sprite/encyclopedia.tscn"),

    SubTag.SALARY: preload("res://sprite/salary.tscn"),
    SubTag.SERVICE: preload("res://sprite/service.tscn"),
    SubTag.SERVANT: preload("res://sprite/servant.tscn"),
    SubTag.STATION: preload("res://sprite/station.tscn"),


    # Indicator
    SubTag.INDICATOR_TOP: preload("res://sprite/indicator_top.tscn"),
    SubTag.INDICATOR_BOTTOM: preload("res://sprite/indicator_bottom.tscn"),
    SubTag.INDICATOR_LEFT: preload("res://sprite/indicator_left.tscn"),
}


static func get_sprite_scene(sub_tag: StringName) -> PackedScene:
    if SPRITE_SCENES.has(sub_tag):
        return SPRITE_SCENES[sub_tag]
    push_error("Invalid sub tag: %s" % sub_tag)
    return null
