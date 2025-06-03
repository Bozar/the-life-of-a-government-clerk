class_name HandleDoor


static func switch_examine_mode(is_enter: bool) -> void:
	for i: Sprite2D in NodeHub.ref_DataHub.door_sprites:
		if is_enter:
			i.add_to_group(SubTag.HIGHLIGHT)
		else:
			i.remove_from_group(SubTag.HIGHLIGHT)

