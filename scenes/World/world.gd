extends Node2D

@onready var player = $Player  # Reference to your player node
#@onready var dialogic_character = load("res://Dialogos/player.dch")
#@onready var timeline_path = "res://Dialogos/timeline.dtl"

func _ready():
	$Fade/Fade_transatision/AnimationPlayer.play("fade_out")
#func _input(event: InputEvent):
	## Trigger the dialog only when the "X" key is pressed and no dialog is running
	#if event is InputEventKey and event.keycode == KEY_X and event.pressed:
		#trigger_dialog()
#func trigger_dialog():
	## Check if no other dialog is currently running
	#if Dialogic.current_timeline == null:
		## Start the dialog timeline with the player as the node the dialog bubble should follow
		#var dialogic_layout = Dialogic.start(timeline_path)
		#dialogic_layout.register_character(dialogic_character, player)
	#else:
		#print("Dialogic timeline is already running.")
