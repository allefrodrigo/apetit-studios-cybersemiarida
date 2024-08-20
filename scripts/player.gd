extends CharacterBody2D

const SPEED = 150.0
const JUMP_VELOCITY = -450.0
const DOUBLE_JUMP_VELOCITY = -400.0
const WALL_SLIDE_VELOCITY = 100.0
const WALL_JUMP_VELOCITY_X = 200.0  # Horizontal velocity for wall jump
const WALL_JUMP_VELOCITY_Y = -400.0  # Vertical velocity for wall jump
const WALL_SLIDE_DELAY = 0.2  # Delay before starting wall slide, in seconds
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var is_jumping = false
var can_double_jump = false
var is_wall_sliding = false
var was_on_floor = false  # Variável para rastrear o estado anterior
var is_crouching = false  # Variável para rastrear o estado de crouch
var wall_slide_timer = 0.0  # Timer to handle wall slide delay

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

	# Handle crouching
	if Input.is_action_pressed("ui_down") and is_on_floor():
		is_crouching = true
		velocity.x = 0  # Disable horizontal movement while crouching
		if animation.animation != "crouch":  # Only play crouch animation if not already playing
			animation.play("crouch")
	else:
		is_crouching = false
		velocity.x = direction * SPEED  # Normal movement speed when not crouching

	# Handle flipping (flip horizontal)
	if direction != 0 and not is_crouching:
		if direction != last_direction:
			animation.flip_h = direction < 0
			last_direction = direction

	# Handle wall slide and wall jump
	if not is_on_floor() and is_on_wall():
		if direction != 0:
			# Handle wall jump (diagonal only)
			if Input.is_action_just_pressed("ui_accept"):
				velocity.x = WALL_JUMP_VELOCITY_X * (last_direction * -1)  # Jump away from the wall horizontally
				velocity.y = WALL_JUMP_VELOCITY_Y  # Apply vertical velocity for wall jump
				is_wall_sliding = false  # Stop wall sliding after jumping
				wall_slide_timer = 0.0  # Reset the wall slide timer
				animation.play("jump")  # Play jump animation
				jump_sfx.play()
			else:
				# Start or continue wall slide after delay
				if wall_slide_timer >= WALL_SLIDE_DELAY:
					if not is_wall_sliding:
						is_wall_sliding = true
						animation.play("slide")  # Play slide animation once
					velocity.y = WALL_SLIDE_VELOCITY  # Control the slide speed
				else:
					wall_slide_timer += delta  # Increment the wall slide timer
		else:
			# If not moving horizontally while on wall, stop wall slide
			is_wall_sliding = false
			wall_slide_timer = 0.0  # Reset the wall slide timer
	else:
		is_wall_sliding = false
		wall_slide_timer = 0.0  # Reset the wall slide timer

	# Handle normal jump
	if Input.is_action_just_pressed("ui_accept") and not is_crouching and not is_wall_sliding:
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
			can_double_jump = true
			play_jump_animation()
			jump_sfx.play()
		elif can_double_jump:
			velocity.y = DOUBLE_JUMP_VELOCITY
			can_double_jump = false
			play_double_jump_animation()

	# Update animation state and detect landing
	if is_on_floor() and not is_crouching:
		if not was_on_floor:  # Verifica se acabou de pousar
			jump_land_sfx.play()  # Toca o som de aterrissagem
		if abs(velocity.x) > 0:
			animation.play("run")
		else:
			animation.play("idle")
		reset_scale()  # Garantir que a escala é resetada no chão
	elif not is_on_floor() and !is_wall_sliding and !is_crouching:
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
	if is_on_floor() and !is_crouching:
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
