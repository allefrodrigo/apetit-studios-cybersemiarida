extends ParallaxBackground
class_name Background

@onready var _clouds: Array = [ 
	$Birds, $Clouds, $FarClouds
]

var _speed_values: Array[float] = [
	8.0, 4.0, 10.0
]
func _physics_process(delta:  float) -> void:
	var _i: int = 0
	for cloud in _clouds:
		cloud.motion_offset.x -= _speed_values[_i] * delta
		_i += 1
		
	
