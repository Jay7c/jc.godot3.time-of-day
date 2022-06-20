tool
class_name TOD_SkyDrawer
# Description:
# - Sky direct drawer using server.
# License:
# - J. Cuéllar 2022 MIT License
# - See: LICENSE File.

# Server.
const VS = VisualServer

# **** Instance ****

# RID
var _instance: RID = RID()

# Get the instance rid.
func get_instance() -> RID: return _instance

# Check the instance.
func check_instance() -> bool:
	if _instance != RID():
		return true
	return false

# ********
#var _world: World = null
#var _mesh: Mesh = null
#var _transform:= Transform(TOD_Const.DEFAULT_BASIS, Vector3.ZERO)
var _transform:= Transform(TOD_Const.DEFAULT_BASIS, Vector3.ZERO)

# **** Clear ****
func _notification(what: int) -> void:
	if NOTIFICATION_PREDELETE:
		VS.free_rid(_instance)
		_instance = RID()
		#_world = null

func clear() -> void:
	VS.free_rid(_instance)
	_instance = RID()

# **** Draw ****

func draw(world: World, mesh: Mesh, material: Material) -> void:
	_instance = VS.instance_create()
	set_visible(true)
	VS.instance_set_scenario(_instance, world.scenario)
	VS.instance_set_base(_instance, mesh.get_rid())
	VS.instance_set_transform(_instance, _transform)
	VS.instance_geometry_set_material_override(_instance, material.get_rid())
	VS.instance_set_extra_visibility_margin(_instance, TOD_Const.MAX_EXTRA_CULL_MARGIN)
	VS.instance_geometry_set_cast_shadows_setting(_instance, VS.SHADOW_CASTING_SETTING_OFF)

func set_visible(value: bool) -> void:
	if check_instance():
		VS.instance_set_visible(_instance, value)

func set_layers(layers: int) -> void:
	if check_instance():
		VS.instance_set_layer_mask(_instance, layers)


# **** Transform ****

func set_origin(value: Vector3) -> void:
	if check_instance():
		_transform.origin = value
		VS.instance_set_transform(_instance, _transform)

func set_origin_offset(value: Vector3) -> void:
	if check_instance():
		_transform.origin = _transform.origin + value
		VS.instance_set_transform(_instance, _transform)


# Set rotated.
# - axis
# - pi
func set_rotated(axis: Vector3, pi: float) -> void:
	if check_instance():
		_transform.basis = _transform.basis.rotated(axis, pi)
		VS.instance_set_transform(_instance, _transform)

# Set transform orbit.
# - origin
# - altitude
# - azimuth
# - radius
func set_orbit(origin: Vector3, altitude: float, azimuth: float, radius: float = 1.0) -> void:
	if !check_instance(): return
	var orbit: Vector3; var finalTr:= _transform
	var setPosFinalize: bool = false
	
	if !setPosFinalize:
		orbit = TOD_Math.to_orbit(altitude, azimuth, radius)
		setPosFinalize = true
	finalTr.origin = finalTr.xform(origin + orbit)
	
	if setPosFinalize:
		finalTr = finalTr.looking_at(origin, Vector3.LEFT)
	
	VS.instance_set_transform(_instance, finalTr)

# Get transform direction.
# -
func get_direction() -> Vector3:
	return -(_transform.origin - TOD_Const.APROXIMATE_ZERO_POSITION)

# Get transform direction using basis
# -
func get_direction_by_rotation() -> Vector3:
	return -(_transform.basis * Vector3.FORWARD)
