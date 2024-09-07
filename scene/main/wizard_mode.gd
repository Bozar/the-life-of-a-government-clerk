class_name WizardMode
extends Node2D


func handle_input(input_tag: StringName) -> void:
    match input_tag:
        InputTag.WIZARD_1:
            _test(input_tag)


func _test(input_tag: StringName) -> void:
    match input_tag:
        InputTag.WIZARD_1:
            get_node("../Cart").add_cart(3)
