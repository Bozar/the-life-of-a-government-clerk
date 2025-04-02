class_name PcSwitchMode


static func examine_mode(is_enter: bool, ref_ActorAction: ActorAction) -> void:
    HandleClerk.switch_examine_mode(is_enter, ref_ActorAction.clerk_states)
    HandleRawFile.switch_examine_mode(is_enter, ref_ActorAction.raw_file_states)
    HandleServant.switch_examine_mode(
            is_enter, ref_ActorAction.get_actor_states(SubTag.SERVANT)
            )

