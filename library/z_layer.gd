class_name ZLayer


const TAG_TO_Z_LAYER: Dictionary = {
	MainTag.GROUND: GROUND,
	MainTag.BUILDING: BUILDING,
	MainTag.TRAP: TRAP,
	MainTag.ACTOR: ACTOR,
	MainTag.INDICATOR: INDICATOR,
}

const GROUND: int = 10
const BUILDING: int = 20
const TRAP: int = 30
const ACTOR: int = 40
const INDICATOR: int = 50

const INVALID_Z_LAYER: int = 0
const MIN_Z_LAYER: int = 1
const MAX_Z_LAYER: int = 99


static func get_z_layer(main_tag: StringName) -> int:
	if TAG_TO_Z_LAYER.has(main_tag):
		return TAG_TO_Z_LAYER[main_tag]
	push_error("Invalid main tag: %s" % main_tag)
	return INVALID_Z_LAYER


static func is_valid_z_layer(z_layer: int) -> bool:
	return (z_layer >= MIN_Z_LAYER) and (z_layer <= MAX_Z_LAYER)

