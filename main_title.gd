extends Node2D

var button_type = null

func _on_quit_pressed() -> void:
	get_tree().quit()


#func _on_fade_timer_timeout() -> void:
	#if button_type == "start" :
		#get_tree().change_scene_to_file("res://game_scene.tscn")
	#if button_type == "options" :
		#get_tree().change_scene_to_file("res://options_cene.tscn")

func _on_texture_button_pressed() -> void:
	$Fade.show()
	$Fade/Fade_timer.start()
	$Fade/Fade_transatision/AnimationPlayer.play("fade_in")	
	
	
func _on_fade_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://World/world.tscn")
