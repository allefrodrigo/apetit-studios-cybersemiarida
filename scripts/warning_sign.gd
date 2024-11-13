extends Node2D

@onready var texture: Sprite2D = $texture
@onready var area_sign: Area2D = $area_sign

const lines : Array[String] = [
"Tomar no cu nicaaaaa",
"É muito bom vê-lo por aqui",
"Espero que esteja preparado...",
"Sua jornada está apenas...",
"...COMEÇANDO!",
]

func _unhandled_input(event):
	if area_sign.get_overlapping_bodies().size() > 0:
		texture.show()
		if event.is_action_pressed("interact") && !DialogManeger.is_message_active:
			texture.hide()
			DialogManeger.start_message(global_position, lines)
	else:
		texture.hide()
		if DialogManeger.dialog_box != null:
			DialogManeger.dialog_box.queue_free()
			DialogManeger.is_message_active = false
