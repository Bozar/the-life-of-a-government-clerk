class_name ShelfState
extends ActorState


const ITEM_TO_VISUAL: Dictionary = {
	SubTag.ATLAS: VisualTag.ACTIVE_1,
	SubTag.BOOK: VisualTag.ACTIVE_2,
	SubTag.CUP: VisualTag.ACTIVE_3,
	SubTag.ENCYCLOPEDIA: VisualTag.ACTIVE_4,
}


var item_tag: StringName:
	set(value):
		if ITEM_TO_VISUAL.has(value):
			item_tag = value
			VisualEffect.switch_sprite(
					sprite, ITEM_TO_VISUAL[value]
			)
		else:
			item_tag = ""
			VisualEffect.switch_sprite(sprite, VisualTag.DEFAULT)

