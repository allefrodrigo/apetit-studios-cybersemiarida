extends CharacterBody2D

# Constantes
const SPEED = 150.0
const JUMP_VELOCITY = -350.0

# Gravidade
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Referências aos nós
@onready var animated_sprite = $AnimatedSprite2D
@onready var dust_sprite = $DustSprite2D
@onready var state_label = $Label

func _physics_process(delta):
	apply_gravity(delta)
	handle_jump()
	handle_movement()
	update_animations()
	move_and_slide()

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

func handle_jump():
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		update_state_text("Jump")

func handle_movement():
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

func update_animations():
	if not is_on_floor():
		dust_sprite.visible = false
		if velocity.y > 0:
			animated_sprite.play("fall")
			update_state_text("Fall")
		else:
			animated_sprite.play("jump")
			update_state_text("Jump")
	elif abs(velocity.x) > 0:
		animated_sprite.play("run")
		animated_sprite.flip_h = (velocity.x < 0)
		dust_sprite.flip_h = animated_sprite.flip_h
		adjust_dust_position(animated_sprite.flip_h)
		update_state_text("Run")
		
		dust_sprite.visible = true
		dust_sprite.play("run_dust")
	else:
		animated_sprite.play("idle")
		update_state_text("Idle")
		dust_sprite.visible = false

func adjust_dust_position(is_flipped):
	dust_sprite.position.x = 10 if is_flipped else -10

func update_state_text(state):
	state_label.text = state
