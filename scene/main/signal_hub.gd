class_name SignalHub
extends Node2D


signal game_over(player_win: bool)
signal turn_started(sprite: Sprite2D)

signal sprite_created(tagged_sprites: Array)
signal sprite_removed(sprites: Array)

signal ui_force_updated()
signal action_pressed(input_tag: InputTag)

