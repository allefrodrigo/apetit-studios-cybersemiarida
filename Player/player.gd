extends CharacterBody2D

# Constantes
const SPEED = 110.0
const MAX_SPEED = 180.0
const JUMP_VELOCITY = -300.0
const ACCELERATION = 50.0  # Aceleração para atingir a velocidade máxima
const WALL_JUMP_FORCE_X = 800.0  # Força horizontal do Wall Jump
const WALL_JUMP_FORCE_Y = 100.0   # Força vertical do Wall Jump (empurrando para baixo)
const WALL_SLIDE_GRAVITY = 50.0  # Velocidade de queda durante o Wall Slide

# Variáveis
var current_speed = SPEED
var is_wall_sliding = false
var can_wall_jump = false
var wall_slide_direction = 0  # Direção do Wall Slide (-1 = esquerda, 1 = direita)
var has_played_wall_slide_animation = false
var last_direction = 1

# Referências aos nós
@onready var animated_sprite = $AnimatedSprite2D  # Sprite do personagem
@onready var dust_sprite = $DustSprite2D          # Sprite da poeira
@onready var state_label = $Label                 # Label para exibir o estado
@onready var wall_slide_label = $Label2           # Label para exibir a direção do Wall Slide

func _physics_process(delta):
	apply_gravity(delta)
	handle_wall_slide()
	handle_jump()
	handle_movement(delta)
	update_animations()
	move_and_slide()

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += ProjectSettings.get_setting("physics/2d/default_gravity") * delta

func handle_wall_slide():
	is_wall_sliding = false
	can_wall_jump = false
	wall_slide_direction = 0

	if is_on_wall() and not is_on_floor() and velocity.y > 0:
		is_wall_sliding = true
		can_wall_jump = true

		var wall_normal = get_wall_normal()
		wall_slide_direction = -sign(wall_normal.x)
		update_wall_text("esquerda" if wall_slide_direction == -1 else "direita")

		velocity.y = WALL_SLIDE_GRAVITY  # Aumentar a velocidade de queda
		update_state_text("Wall Slide")

		# Flip do personagem
		animated_sprite.flip_h = (wall_slide_direction == -1)

		# Animação de Wall Slide
		if not has_played_wall_slide_animation:
			animated_sprite.play("wall_slide")
			has_played_wall_slide_animation = true
	else:
		has_played_wall_slide_animation = false
		wall_slide_label.text = ""  # Limpar o texto quando não estiver em Wall Slide

func handle_jump():
	if Input.is_action_just_pressed("ui_accept"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
			update_state_text("Jump")
		elif can_wall_jump and wall_slide_direction != 0:
			# Wall Jump na direção oposta à parede, sem ganhar altura
			velocity.x = WALL_JUMP_FORCE_X * -wall_slide_direction
			# Impulso vertical para baixo
			velocity.y = WALL_JUMP_FORCE_Y
			update_state_text("Wall Jump")
			print("Wall Jump: Direção", wall_slide_direction)
			print("Velocity após Wall Jump:", velocity)

func handle_movement(delta):
	var input_axis = Input.get_axis("ui_left", "ui_right")
	if input_axis != 0:
		current_speed = min(current_speed + ACCELERATION * delta, MAX_SPEED)
		velocity.x = input_axis * current_speed
		last_direction = sign(input_axis)
	else:
		velocity.x = 0
		current_speed = SPEED  # Resetar a velocidade quando parado

func update_animations():
	if not is_on_floor():
		dust_sprite.visible = false
		if is_wall_sliding:
			# Animação já controlada em handle_wall_slide()
			pass
		elif velocity.y > 0:
			animated_sprite.play("fall")
			update_state_text("Fall")
		else:
			animated_sprite.play("jump")
			update_state_text("Jump")
	elif abs(velocity.x) > 0:
		# Correndo no chão
		animated_sprite.flip_h = (velocity.x < 0)
		dust_sprite.flip_h = animated_sprite.flip_h
		adjust_dust_position(animated_sprite.flip_h)
		animated_sprite.play("run")
		update_state_text("Run")

		# Ativar poeira se estiver na velocidade máxima
		if current_speed >= MAX_SPEED:
			dust_sprite.visible = true
			dust_sprite.play("run_dust")
		else:
			dust_sprite.visible = false
	else:
		# Parado no chão
		animated_sprite.play("idle")
		update_state_text("Idle")
		dust_sprite.visible = false

func adjust_dust_position(is_flipped):
	dust_sprite.position.x = 10 if is_flipped else -10

func update_state_text(state):
	state_label.text = state

func update_wall_text(state):
	wall_slide_label.text = state
	print("Wall Slide Direction:", state)
