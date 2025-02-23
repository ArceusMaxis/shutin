extends Node2D

@export var game_scn : PackedScene

func _ready() -> void:
	$Timer.timeout.connect(get_tree().change_scene_to_packed.bind(game_scn))
