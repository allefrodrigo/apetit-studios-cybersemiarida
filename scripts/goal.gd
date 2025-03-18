extends Area2D

@export_file("*.tscn") var next_scene_path: String

func _ready() -> void:
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		print("[GOAL] Player entrou no goal! handle_goal_reached() chamado.")
		handle_goal_reached(body)

func handle_goal_reached(player: Node) -> void:
	print("[GOAL] handle_goal_reached iniciado. Desativando input e forçando movimento.")
	player.input_enabled = false
	player.forced_walk_direction = 1

	# Pega a câmera do Player
	var player_camera = player.get_node_or_null("Camera2D")
	if player_camera and player_camera.is_current():
		print("[GOAL] (Opcional) Desativando a câmera do Player.")
		# Se quiser congelar completamente a câmera do Player, faça:
		player_camera.set_process_mode(Camera2D.PROCESS_MODE_DISABLED)
		# Ou, se existir a prop "enabled" no Godot 4 do seu template:
		# player_camera.enabled = false

	# Ativa a câmera fixa
	var fixed_camera = get_parent().get_node("CameraFixed")
	if fixed_camera:
		print("[GOAL] Ativando a câmera fixa (make_current).")
		fixed_camera.make_current()

	print("[GOAL] Aguardando player sair do viewport da câmera fixa...")
	await wait_until_player_leaves_screen(player, fixed_camera)
	print("[GOAL] Player saiu do viewport. Iniciando transição.")
	transition_to_next_scene()

func wait_until_player_leaves_screen(player: Node, fixed_camera: Camera2D) -> void:
	var viewport_size = get_viewport().get_visible_rect().size
	print("[GOAL] Iniciando loop para checar se player saiu do viewport da câmera fixa.")

	while true:
		# Converte a posição global do player para o espaço local da câmera fixa
		var local_pos = fixed_camera.to_local(player.global_position)
		var screen_rect = Rect2(Vector2.ZERO, viewport_size)
		print("[DEBUG] local_pos:", local_pos, "viewport_size:", viewport_size)

		if not screen_rect.has_point(local_pos):
			print("[GOAL] Player saiu do viewport!")
			break
		await get_tree().process_frame

	print("[GOAL] Encerrando loop de espera (player saiu do viewport).")

func transition_to_next_scene():
	if next_scene_path.is_empty():
		push_error("[GOAL] ERRO: next_scene_path não foi definido!")
		return

	print("[GOAL] Iniciando transição para a cena:", next_scene_path)
	var transition = preload("res://scenes/transition.tscn").instantiate()
	get_tree().root.add_child(transition)
	transition.play_transition()
	await transition.transition_finished
	print("[GOAL] Transição finalizada. Mudando para a cena:", next_scene_path)
	get_tree().change_scene_to_file(next_scene_path)
