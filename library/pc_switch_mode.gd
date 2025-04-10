class_name PcSwitchMode


static func examine_mode(
        is_enter: bool, ref_DataHub: DataHub, ref_ActorAction: ActorAction
        ) -> void:
    HandleClerk.switch_examine_mode(is_enter, ref_DataHub.clerk_states)
    HandleRawFile.switch_examine_mode(is_enter, ref_DataHub.raw_file_states)
    HandleServant.switch_examine_mode(
            is_enter, ref_ActorAction.get_actor_states(SubTag.SERVANT)
            )


static func highlight_actor() -> void:
    for i: Sprite2D in SpriteState.get_sprites_by_sub_tag(SubTag.HIGHLIGHT):
        if i.visible:
            VisualEffect.set_light_color(i)

