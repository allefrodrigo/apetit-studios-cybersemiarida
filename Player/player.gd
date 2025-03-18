extends CharacterBody2D

const SPEED = 150.0
const JUMP_VELOCITY = -350.0
const ACCELERATION = 800.0
const DECELERATION = 600.0
const COYOTE_TIME = 0.2

@export var sfx_jump : AudioStream
@export var sfx_footstep : AudioStream
@export var sfx_fall : AudioStream  # <-- Som de queda

var footstep_frames : Array = [2, 5]
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var health = 100
var coyote_time_counter = 0.0
var was_on_floor = false

# --- NOVOS CONTROLES DE INPUT ---
var input_enabled = true
var forced_walk_direction = 0  # Se != 0, o player anda sozinho nessa direção

@onready var animated_sprite: AnimatedSprite2D = $Sprite
@onready var state_label: Label = $Label

func _ready() -> void:
	add_to_group("player")
	print("Grupos do jogador:", get_groups())
	respawn_if_needed()

func _physics_process(delta: float) -> void:
	var on_floor = is_on_floor()

	apply_gravity(delta, on_floor)
	update_coyote_time(delta, on_floor)
	
	if input_enabled:
		# Lê o input normalmente
		handle_jump()
		handle_movement(delta)
	else:
		# Se input desativado mas forced_walk_direction != 0, continua andando
		if forced_walk_direction != 0:
			velocity.x = move_toward(velocity.x, forced_walk_direction * SPEED, ACCELERATION * delta)
		else:
			# Se não tem direção forçada, fica parado no eixo X
			velocity.x = move_toward(velocity.x, 0, DECELERATION * delta)
	
	update_animations(on_floor)
	update_stretch_and_squash(delta, on_floor)

	move_and_slide()
	
	# Se acabou de pousar no chão agora, toca o som de queda
	if not was_on_floor and on_floor:
		load_sfx(sfx_fall)
		$sfx_player.play()
	was_on_floor = on_floor

func apply_gravity(delta: float, on_floor: bool) -> void:
	if not on_floor:
		velocity.y += gravity * delta
	else:
		velocity.y = 0

func update_coyote_time(delta: float, on_floor: bool) -> void:
	coyote_time_counter = COYOTE_TIME if on_floor else max(coyote_time_counter - delta, 0)

func handle_jump() -> void:
	if Input.is_action_just_pressed("ui_accept") and coyote_time_counter > 0:
		load_sfx(sfx_jump)
		$sfx_player.play()
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
	
	if state_label.text != state:
		state_label.text = state

func update_stretch_and_squash(delta: float, on_floor: bool) -> void:
	if not on_floor:
		var target_scale = Vector2.ONE
		if velocity.y < 0:
			target_scale = Vector2(0.95, 1.1)
		else:
			target_scale = Vector2(1.1, 0.95)
		animated_sprite.scale = animated_sprite.scale.lerp(target_scale, 5 * delta)
	else:
		animated_sprite.scale = Vector2.ONE

func respawn_if_needed() -> void:
	var checkpoint_data = CheckpointManager.get_checkpoint()
	if checkpoint_data.has("position") and checkpoint_data["position"]:
		global_position = checkpoint_data["position"]
		health = CheckpointManager.player_data["health"]
		print("Respawned at:", checkpoint_data["position"])

func load_sfx(sfx_to_load):
	if $sfx_player.stream != sfx_to_load:
		$sfx_player.stop()
		$sfx_player.stream = sfx_to_load

func _on_sprite_frame_changed() -> void:
	if $Sprite.animation == "idle": return
	if $Sprite.animation == "jump": return
	load_sfx(sfx_footstep)
	if $Sprite.frame in footstep_frames:
		$sfx_player.play()
