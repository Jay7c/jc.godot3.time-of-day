tool
class_name TOD_CloudsBase extends Spatial
# Description:
# - Clouds base class.
# License:
# - J. Cuéllar 2022 MIT License
# - See: LICENSE File.

# **** Resources ****
var _material:= ShaderMaterial.new()
var _mesh:= SphereMesh.new()

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
		
	_update_color()

var layers: int = 4 setget _set_layers
func _set_layers(value: int) -> void:
	layers = value
	_instance.set_layers(value)

var render_priority: int = -125 setget _set_render_priority
func _set_render_priority(value: int) -> void:
	render_priority = value
	_material.render_priority = value

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


var horizon_level: float = 0.0 setget _set_horizon_level
func _set_horizon_level(value: float) -> void:
	horizon_level = value
	_material.set_shader_param("_HorizonLevel", value)

func _on_init() -> void:
	_mesh.radial_segments = 16
	_mesh.rings = 8

func _on_notification(what: int) -> void:
	match(what):
		NOTIFICATION_ENTER_TREE:
			_instance.draw(get_world(), _mesh, _material)
			_instance.set_visible(visible)
			_init_props()
		NOTIFICATION_EXIT_TREE:
			_instance.clear()
		NOTIFICATION_VISIBILITY_CHANGED:
			_instance.set_visible(visible)

func _init_props() -> void:
	_set_sky_path(sky_path)
	_set_layers(layers)
	_set_render_priority(render_priority)
	
	_set_day_color(day_color)
	_set_horizon_color(horizon_color)
	_set_night_color(night_color)
	_set_intensity(intensity)
	_set_horizon_level(horizon_level)

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

func _property_list() -> Array:
	var ret: Array
	ret.push_back({name = "Clouds", type=TYPE_NIL, usage=PROPERTY_USAGE_CATEGORY})
	
	ret.push_back({name = "Render", type=TYPE_NIL, usage=PROPERTY_USAGE_GROUP})
	ret.push_back({name = "layers", type=TYPE_INT, hint=PROPERTY_HINT_LAYERS_3D_RENDER})
	ret.push_back({name = "render_priority", type=TYPE_INT})
	
	ret.push_back({name = "Target", type=TYPE_NIL, usage=PROPERTY_USAGE_GROUP})
	ret.push_back({name = "sky_path", type=TYPE_NODE_PATH})
	
	ret.push_back({name = "Tint", type=TYPE_NIL, usage=PROPERTY_USAGE_GROUP})
	ret.push_back({name = "day_color", type=TYPE_COLOR})
	ret.push_back({name = "horizon_color", type=TYPE_COLOR})
	ret.push_back({name = "night_color", type=TYPE_COLOR})
	ret.push_back({name = "intensity", type=TYPE_REAL})
	
	ret.push_back({name = "Horizon", type=TYPE_NIL, usage=PROPERTY_USAGE_GROUP})
	ret.push_back({name = "horizon_level", type=TYPE_REAL})
	
	return ret

func _init() -> void:
	_on_init()

func _notification(what: int) -> void:
	_on_notification(what)

func _get_property_list() -> Array:
	return _property_list()
