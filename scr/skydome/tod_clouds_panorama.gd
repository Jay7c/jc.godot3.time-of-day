tool
class_name TOD_Panorama extends TOD_CloudsBase
# Description:
# - Panoramic clouds.
# License:
# - J. Cuéllar 2022 MIT License
# - See: LICENSE File.

# **** Resources ****
const _shader: Shader = preload(
	"res://addons/jc.godot3.time-of-day/scr/shaders/clouds_panorama.shader"
)

var panorama: Texture = null setget _set_panorama
func _set_panorama(value: Texture) -> void:
	panorama = value
	_material.set_shader_param("_Texture", value)

var density_channel: int = TOD_Enums.ColorChannel.Red setget _set_density_channel
func _set_density_channel(value: int) -> void:
	density_channel = value
	_material.set_shader_param("_DensityChannel", TOD_Util.get_color_channel(value))

var alpha_channel: int = TOD_Enums.ColorChannel.Blue setget _set_alpha_channel
func _set_alpha_channel(value: int) -> void:
	alpha_channel = value
	_material.set_shader_param("_AlphaChannel", TOD_Util.get_color_channel(value))



var horizon_fade_offset: float = 0.2 setget _set_horizon_fade_offset
func _set_horizon_fade_offset(value: float) -> void:
	horizon_fade_offset = value
	_material.set_shader_param("_HorizonFadeOffset", value)

var horizon_fade: float = 5.0 setget _set_horizon_fade
func _set_horizon_fade(value: float) -> void:
	horizon_fade = value
	_material.set_shader_param("_HorizonFade", value)



enum RotationProcess{ Process = 0, PhysicsProcess }
var rotation_process: int = RotationProcess.Process
var rotation_speed: float = 0.002


func _on_init() -> void:
	._on_init()
	_material.shader = _shader

func _on_notification(what: int) -> void:
	._on_notification(what)
	match(what):
		NOTIFICATION_ENTER_TREE:
			if !Engine.editor_hint:
				if rotation_process == RotationProcess.Process:
					set_process(true)
					set_physics_process(false)
				else:
					set_process(false)
					set_physics_process(true)

func _process(delta: float) -> void:
	if rotation_process == RotationProcess.Process:
		_on_process(delta)

func _physics_process(delta: float) -> void:
	if rotation_process == RotationProcess.PhysicsProcess:
		_on_process(delta)

func _on_process(delta: float) -> void:
	_instance.set_rotated(Vector3.UP, delta * rotation_speed)

func _init_props() -> void:
	._init_props()
	
	_set_panorama(panorama)
	_set_density_channel(density_channel)
	_set_alpha_channel(alpha_channel)
	_set_horizon_fade_offset(horizon_fade_offset)
	_set_horizon_fade(horizon_fade)



func _property_list() -> Array:
	var ret: Array
	ret.append_array(._property_list())
	ret.push_back({name = "Panorama", type=TYPE_NIL, usage=PROPERTY_USAGE_CATEGORY})
	
	ret.push_back({name = "Rotation", type=TYPE_NIL, usage=PROPERTY_USAGE_GROUP})
	ret.push_back({name = "rotation_speed", type=TYPE_REAL})
	ret.push_back({name = "rotation_process", type=TYPE_INT, hint=PROPERTY_HINT_ENUM, hint_string="Process, PhysicProcess"})
	
	ret.push_back({name = "Texture", type=TYPE_NIL, usage=PROPERTY_USAGE_GROUP})
	ret.push_back({name = "density_channel", type=TYPE_INT, hint=PROPERTY_HINT_ENUM, hint_string="Red, Green, Blue, Alpha"})
	ret.push_back({name = "alpha_channel", type=TYPE_INT, hint=PROPERTY_HINT_ENUM, hint_string="Red, Green, Blue, Alpha"})
	ret.push_back({name = "panorama", type=TYPE_OBJECT, hint=PROPERTY_HINT_RESOURCE_TYPE, hint_string="Texture"})
	
	ret.push_back({name = "Horizon", type=TYPE_NIL, usage=PROPERTY_USAGE_GROUP})
	ret.push_back({name = "horizon_fade_offset", type=TYPE_REAL})
	ret.push_back({name = "horizon_fade", type=TYPE_REAL})
	
	
	return ret
