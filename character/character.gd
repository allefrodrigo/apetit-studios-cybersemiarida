extends CharacterBody2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var _gravity := 1000
var _acceleration := 800
var _fall_gravity := 1500
var _friction := 1000
@onready var sfx_jump = $sfx_jump


@onready var texture = $Texture

@export_category("Variables")
@export var _speed: float = 200.0
@export var _jump_velocity: float = -600.0
@export var squash_factor: float = 0.2
@export var stretch_factor: float = 0.2
@export var scale_speed: float = 5.0

func _ready():
	# Ensure the character starts in the visible area
	position = Vector2(200, 200)  # Ajuste a posição conforme necessário
	# Set initial scale to normal
	if texture != null:
		texture.scale = Vector2(1, 1)
	else:
		print("Erro: Texture não encontrado")

func _physics_process(delta):
	_vertical_movement(delta)
	_horizontal_movement(delta)
	_apply_squash_and_stretch(delta)
	move_and_slide()

func _vertical_movement(delta: float) -> void:
	# Add the gravity.
	if is_on_floor():
		pass
	
	if not is_on_floor():
		velocity.y += get_gravity(velocity) * delta

	# Handle jump.
	if Input.is_action_just_released("ui_accept") and velocity.y < 0:
		velocity.y = _jump_velocity / 4
	
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = _jump_velocity
		sfx_jump.play()

func _horizontal_movement(delta: float) -> void:
	var _direction = Input.get_axis("ui_left", "ui_right")
	if _direction:
		velocity.x = move_toward(velocity.x, _direction * _speed, _acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, _friction * delta)

func get_gravity(velocity: Vector2):
	if velocity.y < 0:
		return _gravity
	return _fall_gravity

func _apply_squash_and_stretch(delta: float) -> void:
	if texture == null:
		print("Erro: Texture não encontrado")
		return

	var target_scale_x = 1.0
	var target_scale_y = 1.0

	if not is_on_floor(): # In air (jumping or falling)
		if velocity.y < 0: # Jumping (stretching)
			target_scale_y = 1.0 + stretch_factor
			target_scale_x = 1.0 - squash_factor
		elif velocity.y > 0: # Falling (stretching)
			target_scale_y = 1.0 + stretch_factor
			target_scale_x = 1.0 - squash_factor
	else: # On the ground (normal state)
		target_scale_y = 1.0
		target_scale_x = 1.0

	texture.scale = texture.scale.lerp(Vector2(target_scale_x, target_scale_y), scale_speed * delta)
