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

var layers: int = 4 setget _set_layers
func _set_layers(value: int) -> void:
	layers = value
	_instance.set_layers(value)

var render_priority: int = -125 setget _set_render_priority
func _set_render_priority(value: int) -> void:
	render_priority = value
	_material.render_priority = value


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


func _property_list() -> Array:
	var ret: Array
	ret.push_back({name = "Clouds", type=TYPE_NIL, usage=PROPERTY_USAGE_CATEGORY})
	ret.push_back({name = "layers", type=TYPE_INT, hint=PROPERTY_HINT_LAYERS_3D_RENDER})
	ret.push_back({name = "render_priority", type=TYPE_INT})
	
	ret.push_back({name = "Target", type=TYPE_NIL, usage=PROPERTY_USAGE_GROUP})
	ret.push_back({name = "sky_path", type=TYPE_NODE_PATH})
	
	return ret




func _init() -> void:
	_on_init()

func _notification(what: int) -> void:
	_on_notification(what)

func _get_property_list() -> Array:
	return _property_list()
