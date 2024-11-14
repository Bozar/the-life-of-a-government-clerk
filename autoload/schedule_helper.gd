# class_name ScheduleHelper
extends Node2D


func start_next_turn() -> void:
    NodeHub.ref_Schedule.start_next_turn()
