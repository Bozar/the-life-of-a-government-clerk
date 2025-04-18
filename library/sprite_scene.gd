class_name SpriteScene


const SPRITE_SCENES: Dictionary = {
    # Ground
    SubTag.DUNGEON_FLOOR: preload("res://sprite/dungeon_floor.tscn"),
    SubTag.INTERNAL_FLOOR: preload("res://sprite/internal_floor.tscn"),


    # Trap
    SubTag.ATLAS_ON_DESK: preload("res://sprite/atlas.tscn"),
    SubTag.BOOK_ON_DESK: preload("res://sprite/book.tscn"),
    SubTag.CUP_ON_DESK: preload("res://sprite/cup.tscn"),
    SubTag.ENCYCLOPEDIA_ON_DESK: preload("res://sprite/encyclopedia.tscn"),

    SubTag.TRASH: preload("res://sprite/trash.tscn"),
    SubTag.PROGRESS_BAR: preload("res://sprite/progress_bar.tscn"),


    # Building
    SubTag.WALL: preload("res://sprite/wall.tscn"),
    SubTag.PHONE_BOOTH: preload("res://sprite/phone_booth.tscn"),
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
    SubTag.FIELD_REPORT: preload("res://sprite/field_report.tscn"),

    SubTag.SALARY: preload("res://sprite/salary.tscn"),
    SubTag.GARAGE: preload("res://sprite/garage.tscn"),
    SubTag.STATION: preload("res://sprite/station.tscn"),
    SubTag.PHONE: preload("res://sprite/phone.tscn"),
    SubTag.SHELF: preload("res://sprite/shelf.tscn"),

    SubTag.SERVANT: preload("res://sprite/servant.tscn"),
    SubTag.EMPTY_CART: preload("res://sprite/empty_cart.tscn"),

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

