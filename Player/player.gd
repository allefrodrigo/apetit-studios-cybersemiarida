extends CharacterBody2D

# Constantes
const SPEED = 150.0
const JUMP_VELOCITY = -350.0
const ACCELERATION = 800.0
const DECELERATION = 600.0
const COYOTE_TIME = 0.2

# Gravidade obtida das configurações do projeto
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Dados do jogador
var health = 100

# Variável para controlar o coyote time
var coyote_time_counter = 0.0

# Referências aos nós
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var state_label: Label = $Label

func _ready() -> void:
	add_to_group("player")
	print("Grupos do jogador:", get_groups())
	respawn_if_needed()

func _physics_process(delta: float) -> void:
	var on_floor = is_on_floor()
	
	apply_gravity(delta, on_floor)
	update_coyote_time(delta, on_floor)
	handle_jump()
	handle_movement(delta)
	update_animations(on_floor)
	update_stretch_and_squash(delta, on_floor)
	move_and_slide()

func apply_gravity(delta: float, on_floor: bool) -> void:
	if not on_floor:
		velocity.y += gravity * delta
	else:
		# Reseta a velocidade vertical quando estiver no chão para evitar acumulação de erros
		velocity.y = 0

func update_coyote_time(delta: float, on_floor: bool) -> void:
	coyote_time_counter = COYOTE_TIME if on_floor else max(coyote_time_counter - delta, 0)

func handle_jump() -> void:
	if Input.is_action_just_pressed("ui_accept") and coyote_time_counter > 0:
		velocity.y = JUMP_VELOCITY
		coyote_time_counter = 0

func handle_movement(delta: float) -> void:
	var direction = Input.get_axis("ui_left", "ui_right")
	var target_speed = direction * SPEED
	if abs(target_speed) > 0.1:
		velocity.x = move_toward(velocity.x, target_speed, ACCELERATION * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, DECELERATION * delta)

func update_animations(on_floor: bool) -> void:
	var state = ""
	if not on_floor:
		if velocity.y > 0:
			animated_sprite.play("fall")
			state = "Fall"
		else:
			animated_sprite.play("jump")
			state = "Jump"
	elif abs(velocity.x) > 0.1:
		animated_sprite.play("run")
		animated_sprite.flip_h = (velocity.x < 0)
		state = "Run"
	else:
		animated_sprite.play("idle")
		state = "Idle"
	
	# Atualiza o texto somente se houver mudança
	if state_label.text != state:
		state_label.text = state

func update_stretch_and_squash(delta: float, on_floor: bool) -> void:
	if not on_floor:
		var target_scale = Vector2.ONE
		if velocity.y < 0:
			target_scale = Vector2(0.95, 1.1)
		else:
			target_scale = Vector2(1.1, 0.95)
		# Multiplica o fator de interpolação pelo delta para independência do framerate
		animated_sprite.scale = animated_sprite.scale.lerp(target_scale, 5 * delta)
	else:
		animated_sprite.scale = Vector2.ONE

func respawn_if_needed() -> void:
	var checkpoint_data = CheckpointManager.get_checkpoint()
	if checkpoint_data.has("position") and checkpoint_data["position"]:
		global_position = checkpoint_data["position"]
		health = CheckpointManager.player_data["health"]
		print("Respawned at:", checkpoint_data["position"])
