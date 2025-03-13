extends CharacterBody2D

# Constantes
const SPEED = 150.0
const JUMP_VELOCITY = -350.0
const ACCELERATION = 800.0
const DECELERATION = 600.0

# Gravidade obtida das configurações do projeto
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Dados do jogador
var health = 100

# Referências aos nós
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var state_label: Label = $Label

func _ready() -> void:
	add_to_group("player")
	print("Grupos do jogador:", get_groups())
	respawn_if_needed()

func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	handle_jump()
	handle_movement(delta)
	update_animations()
	update_stretch_and_squash(delta)
	move_and_slide()

func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

func handle_jump() -> void:
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		update_state_text("Jump")

func handle_movement(delta: float) -> void:
	var direction = Input.get_axis("ui_left", "ui_right")
	var target_speed = direction * SPEED
	# Aplica aceleração ou desaceleração suave
	if abs(target_speed) > 0.1:
		velocity.x = move_toward(velocity.x, target_speed, ACCELERATION * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, DECELERATION * delta)

func update_animations() -> void:
	if not is_on_floor():
		if velocity.y > 0:
			animated_sprite.play("fall")
			update_state_text("Fall")
		else:
			animated_sprite.play("jump")
			update_state_text("Jump")
	elif abs(velocity.x) > 0.1:
		animated_sprite.play("run")
		animated_sprite.flip_h = (velocity.x < 0)
		update_state_text("Run")
	else:
		animated_sprite.play("idle")
		update_state_text("Idle")

func update_state_text(state: String) -> void:
	state_label.text = state

# Função para aplicar o efeito "stretch and squash" somente no pulo
func update_stretch_and_squash(delta: float) -> void:
	if not is_on_floor():
		var target_scale = Vector2.ONE
		# Durante o pulo: se estiver subindo, alonga verticalmente; se estiver caindo, alonga horizontalmente
		if velocity.y < 0:
			target_scale.x = 0.95
			target_scale.y = 1.1
		else:
			target_scale.x = 1.1
			target_scale.y = 0.95
		animated_sprite.scale = animated_sprite.scale.lerp(target_scale, 0.3)
	else:
		# Quando no chão, reseta imediatamente a escala para o normal
		animated_sprite.scale = Vector2.ONE

func respawn_if_needed() -> void:
	var checkpoint_data = CheckpointManager.get_checkpoint()
	if checkpoint_data.has("position") and checkpoint_data["position"]:
		global_position = checkpoint_data["position"]
		health = CheckpointManager.player_data["health"]
		print("Respawned at:", checkpoint_data["position"])
