tool
class_name TOD_DynamicClouds extends TOD_CloudsBase

# **** Resources ****
const _shader: Shader = preload(
	"res://addons/jc.godot3.time-of-day/scr/shaders/dynamic_clouds.shader"
)

const _default_noise: Texture = preload(
	"res://addons/jc.godot3.time-of-day/content/graphics/noiseClouds.png"
)

# **** Params ****

# Noise.
var noise: Texture = null setget _set_noise
func _set_noise(value: Texture) -> void:
	noise = value
	
	if value == null:
		noise = _default_noise
	
	_material.set_shader_param("_Noise", noise)

var noise_freq: float = 2.7 setget _set_noise_freq
func _set_noise_freq(value: float) -> void:
	noise_freq = value
	_material.set_shader_param("_NoiseFreq", value)

var size: float = 0.5 setget _set_size
func _set_size(value: float) -> void:
	size = value
	_material.set_shader_param("_Size", value)

var offset:= Vector3(0.64, 0.522, 0.128) setget _set_offset
func _set_offset(value: Vector3) -> void:
	offset = value
	_material.set_shader_param("_Offset", value)

var offset_speed: float = 0.005 setget _set_offset_speed
func _set_offset_speed(value: float) -> void:
	offset_speed = value
	_material.set_shader_param("_OffsetSpeed", value)

# Color.
var thickness: float = 0.0243 setget _set_thickness
func _set_thickness(value: float) -> void:
	thickness = value
	_material.set_shader_param("_Thickness", value)

var coverage: float = 0.6 setget _set_coverage
func _set_coverage(value: float) -> void:
	coverage = value
	_material.set_shader_param("_Coverage", value)

var absorption: float = 6.0 setget _set_absorption
func _set_absorption(value: float) -> void:
	absorption = value
	_material.set_shader_param("_Absorption", value)

# Mie.
var mie_intensity: float = 1.0 setget _set_mie_intensity
func _set_mie_intensity(value: float) -> void:
	mie_intensity = value
	_material.set_shader_param("_MieIntensity", value)

var mie_anisotropy: float = 0.20 setget _set_mie_anisotropy
func _set_mie_anisotropy(value: float) -> void:
	mie_anisotropy = value
	var partial:= TOD_AtmosphereLib.get_partial_mie_phase(value)
	_material.set_shader_param("_PartialMiePhase", partial)

func _on_init() -> void:
	._on_init()
	_material.shader = _shader

func _init_props() -> void:
	._init_props()
	
	_set_noise(noise)
	_set_noise_freq(noise_freq)
	_set_size(size)
	_set_offset(offset)
	_set_offset_speed(offset_speed)
	_set_thickness(thickness)
	_set_coverage(coverage)
	_set_absorption(absorption)
	_set_mie_intensity(mie_intensity)
	_set_mie_anisotropy(mie_anisotropy)


func _property_list() -> Array:
	var ret: Array
	ret.append_array(._property_list())
	ret.push_back({name = "Dynamic Clouds", type=TYPE_NIL, usage=PROPERTY_USAGE_CATEGORY})
	
	ret.push_back({name = "Noise", type=TYPE_NIL, usage=PROPERTY_USAGE_GROUP})
	ret.push_back({name = "noise", type=TYPE_OBJECT, hint = PROPERTY_HINT_FILE, hint_string = "Texture"})
	
	ret.push_back({name = "noise_freq", type=TYPE_REAL})
	ret.push_back({name = "size", type=TYPE_REAL})
	ret.push_back({name = "offset", type=TYPE_VECTOR3})
	ret.push_back({name = "offset_speed", type=TYPE_REAL})
	
	ret.push_back({name = "Density", type=TYPE_NIL, usage=PROPERTY_USAGE_GROUP})
	ret.push_back({name = "thickness", type=TYPE_REAL})
	ret.push_back({name = "coverage", type=TYPE_REAL})
	ret.push_back({name = "absorption", type=TYPE_REAL})
	
	ret.push_back({name = "Mie", type=TYPE_NIL, usage=PROPERTY_USAGE_GROUP})
	ret.push_back({name = "mie_intensity", type=TYPE_REAL})
	ret.push_back({name = "mie_anisotropy", type=TYPE_REAL})
	return ret
