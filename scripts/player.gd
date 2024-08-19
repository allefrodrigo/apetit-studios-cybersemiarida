extends CharacterBody2D

const SPEED = 150.0
const JUMP_VELOCITY = -450.0
const DOUBLE_JUMP_VELOCITY = -400.0
const WALL_SLIDE_VELOCITY = 100.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var is_jumping = false
var can_double_jump = false
var is_wall_sliding = false
var was_on_floor = false  # Variável para rastrear o estado anterior

@onready var animation = $anim as AnimatedSprite2D
@onready var last_direction = 1  # 1 para direita, -1 para esquerda
@onready var jump_sfx = $jump_sfx as AudioStreamPlayer
@onready var jump_land_sfx = $jump_land_sfx as AudioStreamPlayer

func _physics_process(delta):
	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# Get input direction
	var direction = Input.get_axis("ui_left", "ui_right")
	velocity.x = direction * SPEED

	# Handle flipping (flip horizontal)
	if direction != 0:
		if direction != last_direction:
			animation.flip_h = direction < 0
			last_direction = direction

	# Handle wall slide
	if not is_on_floor() and is_on_wall() and direction != 0:
		is_wall_sliding = true
		velocity.y = WALL_SLIDE_VELOCITY
		animation.play("slide")
	else:
		is_wall_sliding = false

	# Handle jump
	if Input.is_action_just_pressed("ui_accept"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
			can_double_jump = true
			play_jump_animation()
			jump_sfx.play()
		elif can_double_jump and not is_on_wall():
			velocity.y = DOUBLE_JUMP_VELOCITY
			can_double_jump = false
			play_double_jump_animation()
		elif is_wall_sliding:
			velocity.y = JUMP_VELOCITY
			velocity.x = SPEED * direction * -1
			can_double_jump = true
			play_jump_animation()

	# Update animation state and detect landing
	if is_on_floor():
		if not was_on_floor:  # Verifica se acabou de pousar
			jump_land_sfx.play()  # Toca o som de aterrissagem
		if abs(velocity.x) > 0:
			animation.play("run")
		else:
			animation.play("idle")
		reset_scale()  # Garantir que a escala é resetada no chão
	elif not is_on_floor() and !is_wall_sliding:
		animation.play("jump")

	# Atualiza o estado de "was_on_floor"
	was_on_floor = is_on_floor()

	# Squash and Stretch
	apply_squash_and_stretch()

	# Move the player
	move_and_slide()

func play_jump_animation():
	animation.play("jump")
	animation.scale = Vector2(1.0, 1.2)  # Stretch on jump

func play_double_jump_animation():
	animation.play("double_jump")
	jump_land_sfx.play() 
	animation.scale = Vector2(1.0, 1.2)  # Stretch on double jump

func apply_squash_and_stretch():
	if is_on_floor():
		if abs(velocity.x) > 0:
			animation.scale = Vector2(1.0, 1.0)  # Reset when running
		else:
			animation.scale = Vector2(1.0, 1.0)  # Normal scale when idle
	else:
		if velocity.y < 0:  # When going up
			animation.scale = Vector2(1.0, 1.2)
		elif velocity.y > 0:  # When coming down
			animation.scale = Vector2(1.2, 0.8)

func reset_scale():
	animation.scale = Vector2(1.0, 1.0)  # Resetar escala para o padrão

func _on_animation_finished():
	reset_scale()  # Resetar a escala quando a animação finalizar
