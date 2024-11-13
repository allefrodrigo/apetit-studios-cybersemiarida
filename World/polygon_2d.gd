extends Polygon2D

# Variáveis para controlar o flicker
var flicker_speed = 20.0  # Velocidade do flicker (quantas vezes por segundo a luz vai piscar)
var flicker_intensity_range = Vector2(0.1, 0.8)  # Faixa de intensidade do flicker

# Referência ao material/shader
var shader_material : ShaderMaterial

func _ready() -> void:
	# Verifica se o material é um ShaderMaterial
	shader_material = self.material as ShaderMaterial

	if shader_material == null:
		print("Material não é um ShaderMaterial")
		return

	# Inicia o flicker
	set_process(true)

func _process(delta: float) -> void:
	# Aplica um efeito de flicker, alterando a intensidade rapidamente
	var flicker_value = randf_range(flicker_intensity_range.x, flicker_intensity_range.y)

	# Define os parâmetros do shader dinamicamente
	#shader_material.set("shader_param/intensity", flicker_value)
	#shader_material.set("shader_param/brightness", flicker_value * 0.5)  # Um controle adicional, se necessário

	# Controle adicional de outros parâmetros (opcional)
	# shader_material.set("shader_param/light_color", Vector3(255, 0, 0))  # Exemplo para mudar a cor da luz
