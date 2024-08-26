extends CharacterBody2D

const SPEED = 110.0
const JUMP_VELOCITY = -300.0
const DOUBLE_JUMP_VELOCITY = -400.0
const WALL_SLIDE_VELOCITY = 100.0
const WALL_JUMP_VELOCITY_X = 200.0
const WALL_JUMP_VELOCITY_Y = -400.0
const WALL_SLIDE_DELAY = 0.2

@export var enable_double_jump: bool = true
@export var enable_wall_jump: bool = true
@export var enable_wall_slide: bool = true

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var is_jumping = false
var can_double_jump = false
var is_wall_sliding = false
var wall_slide_timer = 0.0

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var last_direction = 1

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		can_double_jump = enable_double_jump

	# Handle Double Jump
	if Input.is_action_just_pressed("ui_accept") and not is_on_floor() and can_double_jump:
		velocity.y = DOUBLE_JUMP_VELOCITY
		can_double_jump = false

	# Handle Wall Slide and Wall Jump
	if enable_wall_slide and not is_on_floor() and is_on_wall():
		if Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right"):
			if Input.is_action_just_pressed("ui_accept") and enable_wall_jump:
				velocity.x = WALL_JUMP_VELOCITY_X * (last_direction * -1)
				velocity.y = WALL_JUMP_VELOCITY_Y
				is_wall_sliding = false
				wall_slide_timer = 0.0
				animated_sprite_2d.play("jump")
			else:
				if wall_slide_timer >= WALL_SLIDE_DELAY:
					if not is_wall_sliding:
						is_wall_sliding = true
						animated_sprite_2d.play("slide")
					velocity.y = WALL_SLIDE_VELOCITY
				else:
					wall_slide_timer += delta
		else:
			is_wall_sliding = false
			wall_slide_timer = 0.0
	else:
		is_wall_sliding = false
		wall_slide_timer = 0.0

	# Get the input direction (input_axis) and handle the movement/deceleration.
	var input_axis = Input.get_axis("ui_left", "ui_right")
	if input_axis:
		velocity.x = input_axis * SPEED
		last_direction = sign(input_axis)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# Update animations.
	update_animations(input_axis)

	# Move the character.
	move_and_slide()

func update_animations(input_axis):
	if input_axis != 0:
		animated_sprite_2d.flip_h = input_axis < 0
		animated_sprite_2d.play("run")
	else:
		animated_sprite_2d.play("idle")
		
	if not is_on_floor():
		animated_sprite_2d.play("jump")
