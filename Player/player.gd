extends CharacterBody2D

# Constantes
const SPEED = 150.0
const JUMP_VELOCITY = -350.0

# Gravidade
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Dados do jogador
var health = 100

# Referências aos nós
@onready var animated_sprite = $AnimatedSprite2D
@onready var state_label = $Label

func _ready():
	add_to_group("player")
	print("Grupos do jogador:", get_groups())
	respawn_if_needed() # Reaparece no último checkpoint, se necessário

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
	velocity.x = direction * SPEED

func update_animations():
	if not is_on_floor():
		if velocity.y > 0:
			animated_sprite.play("fall")
			update_state_text("Fall")
		else:
			animated_sprite.play("jump")
			update_state_text("Jump")
	elif velocity.x != 0:
		animated_sprite.play("run")
		animated_sprite.flip_h = (velocity.x < 0)
		update_state_text("Run")
	else:
		animated_sprite.play("idle")
		update_state_text("Idle")

func update_state_text(state):
	state_label.text = state

# Reaparecer no último checkpoint
func respawn_if_needed():
	# Usa o singleton CheckpointManager para pegar os dados do checkpoint
	var checkpoint_data = CheckpointManager.get_checkpoint()
	if checkpoint_data["position"]:
		global_position = checkpoint_data["position"]
		health = CheckpointManager.player_data["health"]
		print("Respawned at:", checkpoint_data["position"])
