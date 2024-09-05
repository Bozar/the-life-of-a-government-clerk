class_name PcAction
extends Node2D


signal ui_force_updated()


enum {
    NORMAL_MODE,
}


var ammo: int:
    get:
        return _ammo


var alert_duration: int:
    get:
        return _alert_duration


var alert_coord: Vector2i:
    get:
        return _alert_coord


var enemy_count: int:
    get:
        return _enemy_count


var progress_bar: int:
    get:
        return _progress_bar


var _ref_ActorAction: ActorAction
var _ref_GameProgress: GameProgress

@onready var _ref_PcFov: PcFov = $PcFov


var _pc: Sprite2D
var _ammo: int = GameData.MAGAZINE
var _game_mode: int = NORMAL_MODE
var _alert_duration: int = 0
var _alert_coord: Vector2i
var _enemy_count: int = GameData.MIN_ENEMY_COUNT
var _progress_bar: int = GameData.MIN_PROGRESS_BAR


func _on_SpriteFactory_sprite_created(tagged_sprites: Array) -> void:
    if _pc != null:
        return

    for i: TaggedSprite in tagged_sprites:
        if i.sub_tag == SubTag.PC:
            _pc = i.sprite
            return


func _on_Schedule_turn_started(sprite: Sprite2D) -> void:
    if not sprite.is_in_group(SubTag.PC):
        return
    # _ref_GameProgress.try_spawn_npc(_pc)
    _ref_PcFov.render_fov(_pc)
    _alert_duration = max(0, _alert_duration - 1)
    # print("%d, %d" % [enemy_count, progress_bar])


func _on_PlayerInput_action_pressed(input_tag: StringName) -> void:
    var coord: Vector2i

    match input_tag:
        InputTag.MOVE_LEFT:
            coord = Vector2i.LEFT
        InputTag.MOVE_RIGHT:
            coord = Vector2i.RIGHT
        InputTag.MOVE_UP:
            coord = Vector2i.UP
        InputTag.MOVE_DOWN:
            coord = Vector2i.DOWN
        _:
            return

    coord += ConvertCoord.get_coord(_pc)
    match _game_mode:
        NORMAL_MODE:
            if not DungeonSize.is_in_dungeon(coord):
                return
            elif SpriteState.has_building_at_coord(coord):
                return
            _move(_pc, coord)
            _end_turn()
            return


func _on_GameProgress_game_over(player_win: bool) -> void:
    _ref_PcFov.render_fov(_pc)
    if not player_win:
        VisualEffect.set_dark_color(_pc)


func _move(pc: Sprite2D, coord: Vector2i) -> void:
    SpriteState.move_sprite(pc, coord)


func _is_impassable(coord: Vector2i) -> bool:
    if not DungeonSize.is_in_dungeon(coord):
        return true
    elif SpriteState.has_building_at_coord(coord):
        return true
    elif SpriteState.has_actor_at_coord(coord):
        return true
    return false


func _end_turn() -> void:
    ScheduleHelper.start_next_turn()
