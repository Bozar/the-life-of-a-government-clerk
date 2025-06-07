class_name PlayerInput
extends Node2D


# HELP_FLAG | DEBUG_FLAG | CHALLENGE_FLAG || GAME_OVER_FLAG
# || FUNCTION_FLAG | GAMEPLAY_FLAG
const GAMEPLAY_FLAG: int = 0b0_000_0_01
const FUNCTION_FLAG: int = 0b0_000_0_10
const GAME_OVER_FLAG: int = 0b0_000_1_00
const HELP_FLAG: int = 0b0_001_0_00
const DEBUG_FLAG: int = 0b0_010_0_00
const CHALLENGE_FLAG: int = 0b0_100_0_00


var _input_flag: int = 0b0_000_0_11
var _previous_input_flag: int = _input_flag


# Convert `InputEvent` to `InputTag`, and then broadcast the result.
func _unhandled_input(event: InputEvent) -> void:
	# Flags that cannot coexist are grouped in an `if` block.
	if _input_flag & FUNCTION_FLAG:
		# Put `Ctrl + X` keys before single key inputs to avoid
		# potential conflicts:
		#> _handle_quit_game: Ctrl + W
		#> _handle_copy_seed: Ctrl + C
		if _handle_quit_game(event):
			return
		elif _handle_copy_seed(event):
			return
		elif _handle_copy_setting(event):
			return
		elif _handle_restart_game(event):
			return
		elif _handle_replay_game(event):
			return
		elif _handle_open_menu(
				event, InputTag.OPEN_HELP_MENU, HELP_FLAG,
				_input_flag
		):
			return
		elif _handle_open_menu(
				event, InputTag.OPEN_DEBUG_MENU, DEBUG_FLAG,
				_input_flag
		):
			return
		elif _handle_open_menu(
				event, InputTag.OPEN_CHALLENGE_MENU,
				CHALLENGE_FLAG, _input_flag
		):
			return
	elif _input_flag & HELP_FLAG:
		if _handle_close_menu(event, _previous_input_flag):
			return
		elif _handle_ui_inputs(event):
			return
	elif _input_flag & DEBUG_FLAG:
		if _handle_close_menu(event, _previous_input_flag):
			return
	elif _input_flag & CHALLENGE_FLAG:
		if _handle_close_menu(event, _previous_input_flag):
			return
		elif _handle_ui_inputs(event):
			return

	if _input_flag & GAMEPLAY_FLAG:
		if _handle_gameplay_inputs(event):
			return
		elif _handle_wizard_inputs(event):
			return
	elif _input_flag & GAME_OVER_FLAG:
		if _handle_mode_inputs(event):
			return
		elif _handle_start_new_game(event):
			return


func _on_SignalHub_turn_started(sprite: Sprite2D) -> void:
	set_process_unhandled_input(sprite.is_in_group(SubTag.PC))


func _on_SignalHub_game_over(_player_win: bool) -> void:
	set_process_unhandled_input(true)
	_input_flag = _input_flag & ~GAMEPLAY_FLAG
	_input_flag = _input_flag | GAME_OVER_FLAG


func _handle_gameplay_inputs(event: InputEvent) -> bool:
	for i: StringName in InputTag.GAME_PLAY_INPUTS:
		if event.is_action_pressed(i):
			NodeHub.ref_SignalHub.action_pressed.emit(i)
			return true
	return false


func _handle_start_new_game(event: InputEvent) -> bool:
	if event.is_action_pressed(InputTag.START_NEW_GAME):
		NodeHub.ref_SignalHub.action_pressed.emit(
				InputTag.START_NEW_GAME
		)
		EndGame.reload()
		return true
	return false


func _handle_restart_game(event: InputEvent) -> bool:
	if event.is_action_pressed(InputTag.RESTART_GAME):
		NodeHub.ref_SignalHub.action_pressed.emit(InputTag.RESTART_GAME)
		EndGame.reload()
		return true
	return false


func _handle_replay_game(event: InputEvent) -> bool:
	if event.is_action_pressed(InputTag.REPLAY_GAME):
		NodeHub.ref_SignalHub.action_pressed.emit(InputTag.REPLAY_GAME)
		EndGame.reload()
		return true
	return false


func _handle_quit_game(event: InputEvent) -> bool:
	if event.is_action_pressed(InputTag.QUIT_GAME):
		EndGame.quit()
		return true
	return false


func _handle_copy_seed(event: InputEvent) -> bool:
	if event.is_action_pressed(InputTag.COPY_SEED):
		NodeHub.ref_SignalHub.action_pressed.emit(InputTag.COPY_SEED)
		return true
	return false


func _handle_copy_setting(event: InputEvent) -> bool:
	if event.is_action_pressed(InputTag.COPY_SETTING):
		NodeHub.ref_SignalHub.action_pressed.emit(InputTag.COPY_SETTING)
		return true
	return false


func _handle_open_menu(
		event: InputEvent, input_tag: StringName, input_flag: int,
		previous_input_flag: int
) -> bool:
	if event.is_action_pressed(input_tag):
		NodeHub.ref_SignalHub.action_pressed.emit(input_tag)
		_previous_input_flag = previous_input_flag
		_input_flag = input_flag
		return true
	return false


func _handle_close_menu(event: InputEvent, previous_input_flag: int) -> bool:
	if event.is_action_pressed(InputTag.CLOSE_MENU):
		NodeHub.ref_SignalHub.action_pressed.emit(InputTag.CLOSE_MENU)
		_input_flag = previous_input_flag
		return true
	return false


func _handle_ui_inputs(event: InputEvent) -> bool:
	for i: StringName in InputTag.UI_INPUTS:
		if event.is_action_pressed(i):
			NodeHub.ref_SignalHub.action_pressed.emit(i)
			return true
	return false


func _handle_wizard_inputs(event: InputEvent) -> bool:
	if not TransferData.wizard_mode:
		return false
	for i: StringName in InputTag.WIZARD_INPUTS:
		if event.is_action_pressed(i):
			NodeHub.ref_SignalHub.action_pressed.emit(i)
			return true
	return false


func _handle_mode_inputs(event: InputEvent) -> bool:
	var sh := NodeHub.ref_SignalHub

	match NodeHub.ref_DataHub.game_mode:
		GameData.NORMAL_MODE:
			if event.is_action_pressed(InputTag.SWITCH_EXAMINE):
				sh.action_pressed.emit(InputTag.SWITCH_EXAMINE)
				return true
			elif event.is_action_pressed(InputTag.SWITCH_HELP):
				sh.action_pressed.emit(InputTag.SWITCH_HELP)
				return true
			return false
		GameData.EXAMINE_MODE, GameData.HELP_MODE:
			if _handle_gameplay_inputs(event):
				return true
			return false
	return false

