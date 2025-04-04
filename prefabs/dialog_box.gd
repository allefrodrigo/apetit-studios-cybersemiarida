extends MarginContainer

signal dialog_finished()

var texts_to_display: Array[String] = []
var current_index : int = 0
var typing_speed : float = 0.05
var is_typing : bool = false

@onready var text_label: Label = $text_container/text_label
@onready var indicator: TextureRect = $indicator
@onready var tween : Tween = get_tree().create_tween()

func _ready() -> void:
	pivot_offset = size / 2
	self.scale = Vector2.ZERO
	indicator.visible = false

	tween.tween_property(self, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK)

		
func show_text():
	if current_index < texts_to_display.size():
		is_typing = true
		indicator.visible = false
		text_label.text = ""
		_type_text(texts_to_display[current_index])
	else:
		_close_dialog()
		
func _type_text(text: String):
	for i in range(text.length()):
		text_label.text += text[i]
		await get_tree().create_timer(typing_speed).timeout
	
	is_typing = false
	indicator.visible = true
	get_tree().paused = true
	
func _close_dialog():
	is_typing = true
	tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.3).set_trans(Tween.TRANS_BACK)
	await tween.finished
	dialog_finished.emit()
	queue_free()
	
func _unhandled_input(event):
	if event.is_action_pressed("ui_accept") and not is_typing:
		if is_typing:
			text_label.text = texts_to_display[current_index] 
			is_typing = false
		else:
			if current_index + 1 < texts_to_display.size():
				current_index += 1
				show_text()
			else:
				get_tree().paused = false
				_close_dialog()
