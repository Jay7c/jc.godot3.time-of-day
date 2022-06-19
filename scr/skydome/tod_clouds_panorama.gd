tool
class_name TOD_Panorama extends Spatial
# Description:
# - Panoramic clouds.
# License:
# - J. Cuéllar 2022 MIT License
# - See: LICENSE File.

# **** Resources ****

var _material:= ShaderMaterial.new()
var _mesh:= SphereMesh.new()
const _shader: Shader = preload(
	"res://addons/jc.godot3.time-of-day/scr/shaders/clouds_panorama.shader"
)

# **** Instances ****
var _instance:= TOD_SkyDrawer.new()

# **** References ****
var _skydome: TOD_Skydome = null

# **** Params ****
var _signals_connected: bool = false

var sky_path: NodePath setget _set_sky_path
func _set_sky_path(value: NodePath) -> void:
	sky_path = value
	if value != null:
		_skydome = get_node_or_null(value) as TOD_Skydome
		
		if _signals_connected:
			_disconnect_signals()
		_connect_signals()

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

var day_color:= Color(0.807843, 0.909804, 1.0, 1.0) setget _set_day_color
func _set_day_color(value: Color) -> void:
	day_color = value
	_update_color()

var horizon_color:= Color(1, 0.772549, 0.415686, 1.0) setget _set_horizon_color
func _set_horizon_color(value: Color) -> void:
	horizon_color = value
	_update_color()

var night_color:= Color(0.082353, 0.164706, 0.32549) setget _set_night_color
func _set_night_color(value: Color) -> void:
	night_color = value
	_update_color()

var intensity: float = 1.5 setget _set_intensity
func _set_intensity(value: float) -> void:
	intensity = value
	_material.set_shader_param("_Intensity", value)

var horizon_fade_offset: float = 0.2 setget _set_horizon_fade_offset
func _set_horizon_fade_offset(value: float) -> void:
	horizon_fade_offset = value
	_material.set_shader_param("_HorizonFadeOffset", value)

var horizon_fade: float = 5.0 setget _set_horizon_fade
func _set_horizon_fade(value: float) -> void:
	horizon_fade = value
	_material.set_shader_param("_HorizonFade", value)

var horizon_level: float = 0.0 setget _set_horizon_level
func _set_horizon_level(value: float) -> void:
	horizon_level = value
	_material.set_shader_param("_HorizonLevel", value)

var layers: int = 4 setget _set_layers
func _set_layers(value: int) -> void:
	layers = value
	_instance.set_layers(value)

var render_priority: int = -125 setget _set_render_priority
func _set_render_priority(value: int) -> void:
	render_priority = value
	_material.render_priority = value

var rotation_speed: float = 0.002

enum RotationProcess{ Process = 0, PhysicsProcess}
var rotation_process: int = RotationProcess.Process

func _init() -> void:
	_mesh.radial_segments = 16
	_mesh.rings = 8
	_material.shader = _shader

func _notification(what: int) -> void:
	match(what):
		NOTIFICATION_ENTER_TREE:
			_instance.draw(get_world(), _mesh, _material)
			_instance.set_visible(visible)
			_init_props()
			
			if !Engine.editor_hint:
				if rotation_process == RotationProcess.Process:
					set_process(true)
					set_physics_process(false)
				else:
					set_process(false)
					set_physics_process(true)

		NOTIFICATION_EXIT_TREE:
			_instance.clear()
		NOTIFICATION_VISIBILITY_CHANGED:
			_instance.set_visible(visible)

func _process(delta: float) -> void:
	if rotation_process == RotationProcess.Process:
		_on_process(delta)

func _physics_process(delta: float) -> void:
	if rotation_process == RotationProcess.PhysicsProcess:
		_on_process(delta)

func _on_process(delta: float) -> void:
	_instance.set_rotated(Vector3.UP, delta * rotation_speed)

func _init_props() -> void:
	_set_sky_path(sky_path)
	_set_panorama(panorama)
	_set_density_channel(density_channel)
	_set_alpha_channel(alpha_channel)
	_set_day_color(day_color)
	_set_horizon_color(horizon_color)
	_set_night_color(night_color)
	_set_horizon_fade_offset(horizon_fade_offset)
	_set_horizon_fade(horizon_fade)
	_set_horizon_level(horizon_level)
	_set_layers(layers)
	_set_intensity(intensity)

func _connect_signals() -> void:
	if _skydome == null: return
	_skydome.connect("sun_direction_changed", self, "_on_sun_direction_changed")
	_skydome.connect("moon_direction_changed", self, "_on_moon_direction_changed")
	_signals_connected = true

func _disconnect_signals() -> void:
	if _skydome == null: return
	_skydome.disconnect("sun_direction_changed", self, "_on_sun_direction_changed")
	_skydome.disconnect("moon_direction_changed", self, "_on_moon_direction_changed")
	_signals_connected = false

func _update_color() -> void:
	_material.set_shader_param("_DayColor", day_color)
	_material.set_shader_param("_HorizonColor", horizon_color)
	
	var nightColor = night_color * max(0.3, _skydome.get_atm_night_intensity()) if _skydome != null else night_color
	_material.set_shader_param("_NightColor", nightColor)

func _on_sun_direction_changed(direction: Vector3) -> void:
	_material.set_shader_param("_SunDirection", direction)
	_update_color()

func _on_moon_direction_changed(direction: Vector3) -> void:
	_material.set_shader_param("_MoonDirection", direction)
	_update_color()

func _get_property_list() -> Array:
	var ret: Array
	ret.push_back({name = "CloudsPanorama", type=TYPE_NIL, usage=PROPERTY_USAGE_CATEGORY})
	ret.push_back({name = "layers", type=TYPE_INT, hint=PROPERTY_HINT_LAYERS_3D_RENDER})
	ret.push_back({name = "render_priority", type=TYPE_INT})
	ret.push_back({name = "rotation_speed", type=TYPE_REAL})
	ret.push_back({name = "rotation_process", type=TYPE_INT, hint=PROPERTY_HINT_ENUM, hint_string="Process, PhysicProcess"})
	
	ret.push_back({name = "Target", type=TYPE_NIL, usage=PROPERTY_USAGE_GROUP})
	ret.push_back({name = "sky_path", type=TYPE_NODE_PATH})
	
	ret.push_back({name = "Texture", type=TYPE_NIL, usage=PROPERTY_USAGE_GROUP})
	ret.push_back({name = "density_channel", type=TYPE_INT, hint=PROPERTY_HINT_ENUM, hint_string="Red, Green, Blue, Alpha"})
	ret.push_back({name = "alpha_channel", type=TYPE_INT, hint=PROPERTY_HINT_ENUM, hint_string="Red, Green, Blue, Alpha"})
	ret.push_back({name = "panorama", type=TYPE_OBJECT, hint=PROPERTY_HINT_RESOURCE_TYPE, hint_string="Texture"})
	
	ret.push_back({name = "Tint", type=TYPE_NIL, usage=PROPERTY_USAGE_GROUP})
	ret.push_back({name = "day_color", type=TYPE_COLOR})
	ret.push_back({name = "horizon_color", type=TYPE_COLOR})
	ret.push_back({name = "night_color", type=TYPE_COLOR})
	ret.push_back({name = "intensity", type=TYPE_REAL})
	
	ret.push_back({name = "Horizon", type=TYPE_NIL, usage=PROPERTY_USAGE_GROUP})
	ret.push_back({name = "horizon_fade_offset", type=TYPE_REAL})
	ret.push_back({name = "horizon_fade", type=TYPE_REAL})
	ret.push_back({name = "horizon_level", type=TYPE_REAL})
	
	return ret
