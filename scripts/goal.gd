extends Area2D

@export_file("*.tscn") var next_scene_path: String

func _ready():
	connect("body_entered", _on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("player"):
		transition_to_next_scene()

func transition_to_next_scene():
	if next_scene_path.is_empty():
		push_error("Next scene path is not set!")
		return
	
	var transition = preload("res://scenes/transition.tscn").instantiate()
	get_tree().root.add_child(transition)
	transition.play_transition()
	await transition.transition_finished
	get_tree().change_scene_to_file(next_scene_path)
