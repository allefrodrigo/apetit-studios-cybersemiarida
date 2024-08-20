extends Node2D

@export var weatherType: String = "clear"  # 'clear', 'rain', 'snow', 'windy'
@export var wind: float = 0.0  # -1 a 1
@export var size: float = 0.3  # 0 a 1
@export var amount: int = 1500  # 100 a 3000
@export var light: float = 1.0  # 0 a 1
@export var snow_darkness: float = 0.2  # 0 a 1
@export var rain_darkness: float = 0.3  # 0 a 1
@export var lightChangeTime: float = 2.0  # 1 a 10
@export var delayWeatherChange: bool = true  # Aguarda a mudança de luz antes de mudar o tempo
@export var weatherChangeTime: float = 2.0  # 1 a 300

var nightColor: Color = Color(1, 1, 1)  # Cor subtraída da cena

@export var followNode: NodePath  # Pode ser definido como o Player ou outro nó que o sistema de clima deve seguir

@onready var snow: GPUParticles2D = $Snow
@onready var rain: GPUParticles2D = $Rain
@onready var leaves: GPUParticles2D = $Leaves
@onready var darkness: ColorRect = $Darkness
var tween: Tween

@onready var follow: Node2D = get_node_or_null(followNode)  # O emissor segue a posição desse nó

var last_control: Control
var last_amount: int

func _ready() -> void:
	tween = create_tween()  # Cria o Tween programaticamente ao carregar a cena
	change_weather()
	darkness_position()
	position = get_viewport_transform().origin + Vector2(get_viewport_rect().size.x / 2, 0)  # Posiciona inicialmente o emissor no centro superior da tela
	snow.process_material.emission_box_extents.x = get_viewport_rect().size.x * 2  # Define a largura do emissor para N vezes o tamanho da tela
	rain.process_material.emission_box_extents.x = get_viewport_rect().size.x * 2  # Define a largura do emissor para N vezes o tamanho da tela
	leaves.process_material.emission_box_extents.x = get_viewport_rect().size.x * 2  # Define a largura do emissor para N vezes o tamanho da tela

func _physics_process(_delta: float) -> void:
	if follow:
		position = follow.position + Vector2(0, -get_viewport_rect().size.y)  # O clima segue a posição do nó em "follow"
		darkness_position()  # A escuridão segue o viewport

func change_weather() -> void:
	# Desativa a emissão de todos os efeitos de partículas
	snow.emitting = false
	rain.emitting = false
	leaves.emitting = false

	if weatherType == "clear":
		apply_rain_settings()
		apply_snow_settings()
		if delayWeatherChange:
			await tween.finished
		change_light(nightColor.darkened(light))

	elif weatherType == "snow":
		change_light(nightColor.darkened(light - snow_darkness * size))
		if delayWeatherChange:
			await tween.finished
		change_amount(snow, amount)
		apply_snow_settings()
		snow.emitting = true

	elif weatherType == "rain":
		change_light(nightColor.darkened(light - rain_darkness * size))
		if delayWeatherChange:
			await tween.finished
		change_amount(rain, amount)
		apply_rain_settings()
		rain.emitting = true

	elif weatherType == "windy":
		# Configurações especiais para o clima "windy" com folhas
		change_light(nightColor.darkened(light))
		if delayWeatherChange:
			await tween.finished
		change_amount(leaves, amount)
		apply_wind_settings()
		leaves.emitting = true

	last_amount = amount

func change_light(new_color: Color) -> void:
	tween.kill()  # Cancela qualquer animação anterior
	tween.tween_property(darkness, "color", new_color, lightChangeTime)

func apply_snow_settings() -> void:
	change_size(snow, size)
	change_wind_speed(snow, 0.5 + abs(wind) / 2)
	change_wind_direction(snow, wind)
	snow.process_material.gravity.x = 70 * wind

func apply_rain_settings() -> void:
	change_size(rain, size)
	change_wind_speed(rain, 0.5 + abs(wind) / 2 + size / 2)
	change_wind_direction(rain, wind)
	rain.process_material.gravity.x = 200 * wind

func apply_wind_settings() -> void:
	# Configurações específicas para vento e folhas
	change_size(leaves, size * 8)  # Aumentar o tamanho das folhas para torná-las visíveis
	change_wind_speed(leaves, 1.0 + abs(wind))
	change_wind_direction(leaves, wind)
	leaves.process_material.gravity.x = 150 * wind

	# Garantir uma distribuição mais aleatória das folhas
	leaves.process_material.angular_velocity = deg_to_rad(50)  # Definir a velocidade angular base maior
	leaves.process_material.angular_velocity_random = 1.0  # Adicionar ainda mais aleatoriedade à velocidade angular

func change_size(weather: GPUParticles2D, new_size: float) -> void:
	tween.kill()  # Cancela qualquer animação anterior
	tween.tween_property(weather.process_material, "scale", new_size, weatherChangeTime)

func change_amount(weather: GPUParticles2D, _new_amount: int) -> void:
	if last_amount != amount:
		if weather.emitting == true:
			weather.preprocess = weather.lifetime * 2
		weather.amount = amount
	else:
		weather.preprocess = 0

func change_wind_direction(weather: GPUParticles2D, new_wind: float) -> void:
	tween.kill()  # Cancela qualquer animação anterior
	tween.tween_property(weather.process_material, "direction:x", new_wind, weatherChangeTime)

func change_wind_speed(weather: GPUParticles2D, new_speed: float) -> void:
	tween.kill()  # Cancela qualquer animação anterior
	tween.tween_property(weather, "speed_scale", new_speed, weatherChangeTime)

func darkness_position() -> void:
	darkness.custom_minimum_size = get_viewport_rect().size * 4
	darkness.position = get_viewport_rect().position - Vector2(get_viewport_rect().size.x * 2, get_viewport_rect().size.y)
