extends Area2D

#@onready var transition: CanvasLayer = $"../transition"
@export var next_level : String = "world_01"

func _on_body_entered(body):
	var scene_to_spawn = preload("res://Pickups/Feedback/feedback.tscn")
	var new_scene_instance = scene_to_spawn.instantiate()
	get_tree().current_scene.add_child(new_scene_instance)  # Add the instance as a child of the current scene
	new_scene_instance.global_position = global_position
	if body.name == "Player" and !next_level == "":
		pass
		#transition.change_scene(next_level)
	else:
		print("no scene")
