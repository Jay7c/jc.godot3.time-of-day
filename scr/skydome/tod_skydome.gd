tool
class_name TOD_Skydome extends Spatial
# Description:
# - Skydome manager.
# License:
# - J. Cuéllar 2022 MIT License
# - See: LICENSE File.

# **** Resources ****
var _resources:= TOD_SkyResources.new()

# **** Instances ****
var _near_space_instance:= TOD_SkyDrawer.new()
var _sky_instance:= TOD_SkyDrawer.new()
var _fog_instance:= TOD_SkyDrawer.new()

# Moon instance.
var _moon_instance: Viewport = null
var _moon_vpt: ViewportTexture = null
var _moon_instance_transform: Spatial = null
var _moon_mesh_instance: MeshInstance = null

func check_moon_instance() -> bool:
	_moon_instance = get_node_or_null("MoonInstance") as Viewport
	if _moon_instance == null:
		return false
	return true

var _init_properties_ok: bool = false
signal is_day(value)

# **** Global ****
var sky_visible: bool = true setget _set_sky_visible
func _set_sky_visible(value: bool) -> void:
	sky_visible = value
	_sky_instance.set_visible(value)
	_near_space_instance.set_visible(value)

var tonemap: float = 0.0 setget _set_tonemap
func _set_tonemap(value: float) -> void:
	tonemap = value
	_set_color_correction_params()

var exposure: float = 1.3 setget _set_exposure
func _set_exposure(value: float) -> void:
	exposure = value
	_set_color_correction_params()

var horizon_level: float = 0.0 setget _set_horizon_level
func _set_horizon_level(value: float) -> void:
	horizon_level = value
	_resources.near_space_material.set_shader_param(TOD_Const.P_HORIZON_LEVEL, value)
	_resources.sky_material.set_shader_param(TOD_Const.P_HORIZON_LEVEL, value)

var ground_color:= Color(0.435294, 0.435294, 0.435294, 1.0) setget _set_ground_color
func _set_ground_color(value: Color) -> void:
	ground_color = value
	_resources.sky_material.set_shader_param(TOD_Const.P_GROUND_COLOR, value)

# Layer 3.
var sky_layers: int = 4 setget _set_sky_layers
func _set_sky_layers(value: int) -> void:
	sky_layers = value
	_sky_instance.set_layers(value)

# Layer 4
var near_space_layers: int = 8 setget _set_near_space_layers
func _set_near_space_layers(value: int) -> void:
	near_space_layers = value
	_near_space_instance.set_layers(value)

var sky_render_priority: int = -128 setget _set_sky_render_priority
func _set_sky_render_priority(value: int) -> void:
	sky_render_priority = value
	_resources.setup_render_priority(value)

# **** Near Space ****
var sun_altitude: float = 68.8916 setget _set_sun_altitude
func _set_sun_altitude(value: float) -> void:
	sun_altitude = value
	_set_sun_coords()

var sun_azimuth: float = 21.9201 setget _set_sun_azimuth
func _set_sun_azimuth(value: float) -> void:
	sun_azimuth = value
	_set_sun_coords()

var sun_disk_color:= Color(0.996078, 0.380392, 0.141176) setget _set_sun_disk_color
func _set_sun_disk_color(value: Color) -> void:
	sun_disk_color = value
	_resources.near_space_material.set_shader_param(TOD_Const.P_SUN_DISK_COLOR, value)

var sun_disk_intensity: float = 3.0 setget _set_sun_disk_intensity
func _set_sun_disk_intensity(value: float) -> void:
	sun_disk_intensity = value
	_resources.near_space_material.set_shader_param(TOD_Const.P_SUN_DISK_INTENSITY, value)

var sun_disk_size: float = 0.02 setget _set_sun_disk_size
func _set_sun_disk_size(value: float) -> void:
	sun_disk_size = value
	_resources.near_space_material.set_shader_param(TOD_Const.P_SUN_DISK_SIZE, value)

func get_sun_direction() -> Vector3: 
	return _sun_transform.origin - TOD_Const.APROXIMATE_ZERO_POSITION

var _sun_transform:= Transform()

signal sun_direction_changed(value)
signal sun_transform_changed(value)

# **** Sun Light ****
var sun_light_color:= Color(0.984314, 0.843137, 0.788235) setget _set_sun_light_color
func _set_sun_light_color(value: Color) -> void:
	sun_light_color = value
	_update_sun_light_color()

var sun_horizon_light_color:= Color(1.0, 0.717647, 0.647059) setget _set_sun_horizon_light_color
func _set_sun_horizon_light_color(value: Color) -> void:
	sun_horizon_light_color = value
	_update_sun_light_color()

var sun_light_energy: float = 2.0 setget _set_sun_light_energy
func _set_sun_light_energy(value: float) -> void:
	sun_light_energy = value
	_update_sun_light_energy()

var sun_light_energy_curve: Curve = null setget _set_sun_light_energy_curve
func _set_sun_light_energy_curve(value: Curve) -> void:
	sun_light_energy_curve = value
	_update_sun_light_energy()

var sun_light_path: NodePath setget _set_sun_light_path
func _set_sun_light_path(value: NodePath) -> void:
	sun_light_path = value
	if value != null:
		_sun_light_node = get_node_or_null(value) as DirectionalLight
	
	_sun_light_ready = _sun_light_node != null
	
	_set_sun_coords()

var _sun_light_altitude_mult: float = 0.0
var _sun_light_ready: bool = false
var _sun_light_node: DirectionalLight = null

# **** Moon ****
var moon_altitude: float = -35.5 setget _set_moon_altitude
func _set_moon_altitude(value: float) -> void:
	moon_altitude = value
	_set_moon_coords()

var moon_azimuth: float = -35.5 setget _set_moon_azimuth
func _set_moon_azimuth(value: float) -> void:
	moon_azimuth = value
	_set_moon_coords()

var moon_color:= Color.white setget _set_moon_color
func _set_moon_color(value: Color) -> void:
	moon_color = value
	_resources.near_space_material.set_shader_param(TOD_Const.P_MOON_COLOR, value)

var moon_size: float = 0.08 setget _set_moon_size
func _set_moon_size(value: float) -> void:
	moon_size = value
	_resources.near_space_material.set_shader_param(TOD_Const.P_MOON_SIZE, value)

var enable_set_moon_texture: bool = false setget _enable_set_moon_texture
func _enable_set_moon_texture(value: bool) -> void:
	enable_set_moon_texture = value
	
	if !enable_set_moon_texture:
		_set_moon_texture(_resources.moon_texture)
	
	property_list_changed_notify()

var moon_texture: Texture = null setget _set_moon_texture
func _set_moon_texture(value: Texture) -> void:
	moon_texture = value
	_resources.moon_material.set_shader_param(TOD_Const.P_TEXTURE, value)

var moon_resolution: int = TOD_Enums.Resolution.R128 setget _set_moon_resolution
func _set_moon_resolution(value: int) -> void:
	moon_resolution = value
	if !_init_properties_ok:
		return
	assert(_moon_instance != null, "Moon instace not found")
	
	match(value):
		TOD_Enums.Resolution.R64: _moon_instance.size = Vector2.ONE * 64
		TOD_Enums.Resolution.R128: _moon_instance.size = Vector2.ONE * 128
		TOD_Enums.Resolution.R256: _moon_instance.size = Vector2.ONE * 256
		TOD_Enums.Resolution.R512: _moon_instance.size = Vector2.ONE * 512
		TOD_Enums.Resolution.R1024: _moon_instance.size = Vector2.ONE * 1024
	_moon_vpt = _moon_instance.get_texture()
	_resources.near_space_material.set_shader_param(TOD_Const.P_MOON_TEXTURE, _moon_vpt)

func get_moon_direction() -> Vector3:
	return _moon_transform.origin - TOD_Const.APROXIMATE_ZERO_POSITION

var _moon_transform:= Transform()

signal moon_direction_changed(value)
signal moon_transform_changed(value)

# **** Moon Light ****
var moon_light_color:= Color(0.788235, 0.870588, 0.984314) setget _set_moon_light_color
func _set_moon_light_color(value: Color) -> void:
	moon_light_color = value
	if _moon_light_ready:
		_moon_light_node.light_color = value

var moon_light_energy: float = 0.2 setget _set_moon_light_energy
func _set_moon_light_energy(value: float) -> void:
	moon_light_energy = value
	_update_moon_light_energy()

var moon_light_path: NodePath setget _set_moon_light_path
func _set_moon_light_path(value: NodePath) -> void:
	moon_light_path = value
	if moon_light_path != null:
		_moon_light_node = get_node_or_null(value) as DirectionalLight
	
	_moon_light_ready = _moon_light_node != null
	
	_set_moon_coords()

var _moon_light_node: DirectionalLight = null
var _moon_light_ready: bool = false
var _moon_light_altitude_mult: float = 0.0

var _light_enable: bool
var _sun_light_initial_visible: bool
var _moon_light_initial_visible: bool

# **** Atmosphere ****
var atm_quality: int = TOD_Enums.AtmosphereQuality.PerPixel setget _set_atm_quality
func _set_atm_quality(value: int) -> void:
	atm_quality = value
	_resources.set_atmosphere_quality(value)

var atm_wavelenghts:= Vector3(680.0, 550.0, 440.0) setget _set_atm_wavelenghts
func _set_atm_wavelenghts(value: Vector3) -> void:
	atm_wavelenghts = value
	_set_beta_ray()

var atm_darkness: float = 0.7 setget _set_atm_darkness
func _set_atm_darkness(value: float) -> void:
	atm_darkness = value
	_resources.sky_material.set_shader_param(TOD_Const.P_ATM_DARKNESS, value)
	_resources.fog_material.set_shader_param(TOD_Const.P_ATM_DARKNESS, value)

var atm_sun_intensity: float = 30.0 setget _set_atm_sun_intensity
func _set_atm_sun_intensity(value: float) -> void:
	atm_sun_intensity = value
	_resources.sky_material.set_shader_param(TOD_Const.P_ATM_SUN_INTENSITY, value)
	_resources.fog_material.set_shader_param(TOD_Const.P_ATM_SUN_INTENSITY, value)

var atm_day_tint:= Color(0.705882, 0.803922, 0.984314) setget _set_atm_day_tint
func _set_atm_day_tint(value: Color) -> void:
	atm_day_tint = value
	_resources.sky_material.set_shader_param(TOD_Const.P_ATM_DAY_TINT, value)
	_resources.fog_material.set_shader_param(TOD_Const.P_ATM_DAY_TINT, value)
	_update_enviro()

var atm_horizon_light_tint:= Color(1, 0.839216, 0.517647) setget _set_atm_horizon_light_tint
func _set_atm_horizon_light_tint(value: Color) -> void:
	atm_horizon_light_tint = value
	_resources.sky_material.set_shader_param(TOD_Const.P_ATM_HORIZON_LIGHT_TINT, value)
	_resources.fog_material.set_shader_param(TOD_Const.P_ATM_HORIZON_LIGHT_TINT, value)
	_update_enviro()

var atm_enable_moon_scatter_mode: bool = false setget _set_atm_enable_moon_scatter_mode
func _set_atm_enable_moon_scatter_mode(value: bool) -> void:
	atm_enable_moon_scatter_mode = value
	_set_night_intensity()

func get_atm_moon_phases_mul() -> float:
	if !atm_enable_moon_scatter_mode:
		return get_atm_night_intensity()
		
	return TOD_Math.saturate(-get_sun_direction().dot(get_moon_direction()) + 0.60)

func get_atm_night_intensity() -> float:
	if !atm_enable_moon_scatter_mode:
		return TOD_Math.saturate(-get_sun_direction().y + 0.30)
	
	return TOD_Math.saturate(get_moon_direction().y * get_atm_moon_phases_mul())

var atm_night_tint:= Color(0.254902, 0.337255, 0.447059) setget _set_atm_night_tint
func _set_atm_night_tint(value: Color) -> void:
	atm_night_tint = value
	_set_night_intensity()
	_update_enviro()

var atm_level_params:= Vector3(1.0, 0.0, 0.0) setget _set_atm_level_params
func _set_atm_level_params(value: Vector3) -> void:
	atm_level_params = value
	_resources.sky_material.set_shader_param(TOD_Const.P_ATM_LEVEL_PARAMS, value)
	_set_fog_atm_level_params_offset(fog_atm_level_params_offset)

var atm_thickness: float = 0.7 setget _set_atm_thickness
func _set_atm_thickness(value: float) -> void:
	atm_thickness = value
	_resources.sky_material.set_shader_param(TOD_Const.P_ATM_THICKNESS, value)
	_resources.fog_material.set_shader_param(TOD_Const.P_ATM_THICKNESS, value)

var atm_mie: float = 0.07 setget _set_atm_mie
func _set_atm_mie(value: float) -> void:
	atm_mie = value
	_set_beta_mie()

var atm_turbidity: float = 0.001 setget _set_atm_turbidity
func _set_atm_turbidity(value: float) -> void:
	atm_turbidity = value
	_set_beta_mie()

var atm_sun_mie_tint:= Color(1.0, 0.858824, 0.717647, 1.0) setget _set_atm_sun_mie_tint
func _set_atm_sun_mie_tint(value: Color) -> void:
	atm_sun_mie_tint = value
	_resources.sky_material.set_shader_param(TOD_Const.P_ATM_SUN_MIE_TINT, value)
	_resources.fog_material.set_shader_param(TOD_Const.P_ATM_SUN_MIE_TINT, value)

var atm_sun_mie_intensity: float = 1.0 setget _set_atm_sun_mie_intensity
func _set_atm_sun_mie_intensity(value: float) -> void:
	atm_sun_mie_intensity = value
	_resources.sky_material.set_shader_param(TOD_Const.P_ATM_SUN_MIE_INTENSITY, value)
	_resources.fog_material.set_shader_param(TOD_Const.P_ATM_SUN_MIE_INTENSITY, value)

var atm_sun_mie_anisotropy: float = 0.8 setget _set_atm_sun_mie_anisotropy
func _set_atm_sun_mie_anisotropy(value: float) -> void:
	atm_sun_mie_anisotropy = value
	var partial = TOD_AtmosphereLib.get_partial_mie_phase(value)
	_resources.sky_material.set_shader_param(TOD_Const.P_ATM_SUN_PARTIAL_MIE_PHASE, partial)
	_resources.fog_material.set_shader_param(TOD_Const.P_ATM_SUN_PARTIAL_MIE_PHASE, partial)

var atm_moon_mie_tint:= Color(0.12549, 0.168627, 0.27451) setget _set_atm_moon_mie_tint
func _set_atm_moon_mie_tint(value: Color) -> void:
	atm_moon_mie_tint = value
	_resources.sky_material.set_shader_param(TOD_Const.P_ATM_MOON_MIE_TINT, value)
	_resources.fog_material.set_shader_param(TOD_Const.P_ATM_MOON_MIE_TINT, value)

var atm_moon_mie_intensity: float = 0.7 setget _set_atm_moon_mie_intensity
func _set_atm_moon_mie_intensity(value: float) -> void:
	atm_moon_mie_intensity = value
	_resources.sky_material.set_shader_param(TOD_Const.P_ATM_MOON_MIE_INTENSITY, value * get_atm_moon_phases_mul())
	_resources.fog_material.set_shader_param(TOD_Const.P_ATM_MOON_MIE_INTENSITY, value * get_atm_moon_phases_mul())

var atm_moon_mie_anisotropy: float = 0.8 setget _set_atm_moon_mie_anisotropy
func _set_atm_moon_mie_anisotropy(value: float) -> void:
	atm_moon_mie_anisotropy = value
	var partial = TOD_AtmosphereLib.get_partial_mie_phase(value)
	_resources.sky_material.set_shader_param(TOD_Const.P_ATM_MOON_PARTIAL_MIE_PHASE, partial)
	_resources.fog_material.set_shader_param(TOD_Const.P_ATM_MOON_PARTIAL_MIE_PHASE, partial)

# **** Atmospheric Fog ****
var fog_visible: bool = true setget _set_fog_visible
func _set_fog_visible(value: bool) -> void:
	fog_visible = value
	_fog_instance.set_visible(value)

var fog_atm_level_params_offset:= Vector3(1.0, 0.0, -1.0) setget _set_fog_atm_level_params_offset
func _set_fog_atm_level_params_offset(value: Vector3) -> void:
	fog_atm_level_params_offset = value
	_resources.fog_material.set_shader_param(TOD_Const.P_ATM_LEVEL_PARAMS, value + atm_level_params)

var fog_density: float = 0.00015 setget _set_fog_density
func _set_fog_density(value: float) -> void:
	fog_density = value
	_resources.fog_material.set_shader_param(TOD_Const.P_FOG_DENSITY, value)

var fog_start: float = 0.0 setget _set_fog_start
func _set_fog_start(value: float) -> void:
	fog_start = value
	_resources.fog_material.set_shader_param(TOD_Const.P_FOG_START, value)

var fog_end: float = 1000.0 setget _set_fog_end
func _set_fog_end(value: float) -> void:
	fog_end = value
	_resources.fog_material.set_shader_param(TOD_Const.P_FOG_END, value)

var fog_rayleigh_depth: float = 0.116 setget _set_fog_rayleigh_depth
func _set_fog_rayleigh_depth(value: float) -> void:
	fog_rayleigh_depth = value
	_resources.fog_material.set_shader_param(TOD_Const.P_FOG_RAYLEIGH_DEPTH, value)

var fog_mie_depth: float = 0.0001 setget _set_fog_mie_depth
func _set_fog_mie_depth(value: float) -> void:
	fog_mie_depth = value
	_resources.fog_material.set_shader_param(TOD_Const.P_FOG_MIE_DEPTH, value)

var fog_falloff: float = 3.0 setget _set_fog_falloff
func _set_fog_falloff(value: float) -> void:
	fog_falloff = value
	_resources.fog_material.set_shader_param(TOD_Const.P_FOG_FALLOFF, value)

var fog_layers: int = 524288 setget _set_fog_layers
func _set_fog_layers(value: int) -> void: 
	fog_layers = value
	_fog_instance.set_layers(value)

var fog_render_priority: int = -100 setget _set_fog_render_priority
func _set_fog_render_priority(value: int) -> void:
	fog_render_priority = value
	_resources.setup_fog_render_priority(value)

func get_fog_atm_night_intensity() -> float:
	if !atm_enable_moon_scatter_mode:
		return TOD_Math.saturate(-get_sun_direction().y + 0.70)
	return TOD_Math.saturate(get_moon_direction().y) * get_atm_moon_phases_mul()

# **** Deep Space ****
var deep_space_euler:= Vector3(-0.752, -2.56, 0.0) setget _set_deep_space_euler
func _set_deep_space_euler(value: Vector3) -> void:
	deep_space_euler = value
	_deep_space_basis = Basis(value)
	deep_space_quat = _deep_space_basis.get_rotation_quat()
	_resources.sky_material.set_shader_param(TOD_Const.P_DEEP_SPACE_MATRIX, _deep_space_basis)

var deep_space_quat:= Quat.IDENTITY setget _set_deep_space_quat
func _set_deep_space_quat(value: Quat) -> void:
	deep_space_quat = value
	_deep_space_basis = Basis(value)
	deep_space_euler = _deep_space_basis.get_euler()
	_resources.sky_material.set_shader_param(TOD_Const.P_DEEP_SPACE_MATRIX, _deep_space_basis)

var _deep_space_basis:= Basis()

var background_color:= Color(0.341176, 0.341176, 0.341176, 0.768627) setget _set_background_color
func _set_background_color(value: Color) -> void:
	background_color = value
	_resources.sky_material.set_shader_param(TOD_Const.P_BACKGROUND_COLOR, value)

var set_background_texture: bool = false setget _set_set_background_texture
func _set_set_background_texture(value: bool) -> void:
	set_background_texture = value
	
	if !value:
		_set_background_texture(_resources.background_texture)
	
	property_list_changed_notify()

var background_texture: Texture = null setget _set_background_texture
func _set_background_texture(value: Texture) -> void:
	background_texture = value
	_resources.sky_material.set_shader_param(TOD_Const.P_BACKGROUND_TEXTURE, value)

var stars_field_color:= Color.white setget _set_stars_field_color
func _set_stars_field_color(value: Color) -> void:
	stars_field_color = value
	_resources.sky_material.set_shader_param("_StarsFieldColor", value)

var set_stars_field_texture: bool = false setget _set_set_stars_field_texture
func _set_set_stars_field_texture(value: bool)-> void:
	set_stars_field_texture = value
	
	if !value:
		_set_stars_field_texture(_resources.stars_field_texture)
	
	property_list_changed_notify()

var stars_field_texture: Texture = null setget _set_stars_field_texture
func _set_stars_field_texture(value: Texture) -> void:
	stars_field_texture = value
	_resources.sky_material.set_shader_param(TOD_Const.P_STARS_FIELD_COLOR, value)

var stars_scintillation: float = 0.75 setget _set_stars_scintillation
func _set_stars_scintillation(value: float) -> void:
	stars_scintillation = value
	_resources.sky_material.set_shader_param(TOD_Const.P_STARS_FIELD_SCINTILLATION, value)

var stars_scintillation_speed: float = 0.01 setget _set_stars_scintillation_speed
func _set_stars_scintillation_speed(value: float) -> void:
	stars_scintillation_speed = value
	_resources.sky_material.set_shader_param(TOD_Const.P_STARS_FIELD_SCONTILLATION_SPEED, value)

# **** Environment ****
var _enviro: Environment = null
var enviro_container: NodePath setget _set_enviro_container
func _set_enviro_container(value: NodePath) -> void:
	enviro_container = value
	if value != null:
		var container = get_node_or_null(value)
		if container is Camera || container is WorldEnvironment:
			_enviro = container.environment

var ambient_gradient: Gradient = null setget _set_ambient_gradient
func _set_ambient_gradient(value: Gradient) -> void:
	ambient_gradient = value
	_update_enviro()

var enable_enviro_fog: bool = false setget _set_enable_enviro_fog
func _set_enable_enviro_fog(value: bool) -> void:
	enable_enviro_fog = value
	_update_enviro()
	property_list_changed_notify()

var enviro_fog_gradient: Gradient = null setget _set_enviro_fog_gradient
func _set_enviro_fog_gradient(value: Gradient) -> void:
	enviro_fog_gradient = value
	_update_enviro()

func _init() -> void:
	_resources.setup_render_priority(sky_render_priority)
	_resources.setup_shaders()
	_resources.setup_moon_resources()
	_resources.setup_fog_render_priority(fog_render_priority)
	_force_setup_moon_instances()
	_resources.sky_material.set_shader_param(TOD_Const.P_NOISE_TEX, _resources.stars_field_noise)

func _notification(what: int) -> void:
	match(what):
		NOTIFICATION_ENTER_TREE:
			_near_space_instance.draw(get_world(), _resources.full_screen_quad, _resources.near_space_material)
			_sky_instance.draw(get_world(), _resources.dome_mesh, _resources.sky_material)
			_fog_instance.draw(get_world(), _resources.full_screen_quad, _resources.fog_material)
			_build_moon()
			_init_properties()
			if _sun_light_ready: 
				_sun_light_initial_visible = _sun_light_node.visible
				_sun_light_node.visible = !_sun_light_node.visible
			if _moon_light_ready:
				_moon_light_initial_visible = _moon_light_node.visible
				_moon_light_node.visible = !_moon_light_node.visible
		
		NOTIFICATION_POST_ENTER_TREE:
			if _sun_light_ready: _sun_light_node.visible = _sun_light_initial_visible
			if _moon_light_ready: _moon_light_node.visible = _moon_light_initial_visible
		
		NOTIFICATION_EXIT_TREE:
			_near_space_instance.clear()
			_sky_instance.clear()
			_fog_instance.clear()
		
		NOTIFICATION_READY:
			_set_sun_coords()
			_set_moon_coords()

func _init_properties() -> void:
	_init_properties_ok = true
	
	# General
	_set_sky_visible(sky_visible)
	_set_tonemap(tonemap)
	_set_exposure(exposure)
	_set_near_space_layers(near_space_layers)
	_set_sky_layers(sky_layers)
	
	# Sun.
	_set_sun_disk_color(sun_disk_color)
	_set_sun_disk_intensity(sun_disk_intensity)
	_set_sun_disk_size(sun_disk_size)
	
	# Sun light
	_set_sun_light_color(sun_light_color)
	_set_sun_horizon_light_color(sun_horizon_light_color)
	_set_sun_light_energy(sun_light_energy)
	_set_sun_light_energy_curve(sun_light_energy_curve)
	_set_sun_light_path(sun_light_path)
	
	# Moon.
	_set_moon_azimuth(moon_altitude)
	_set_moon_altitude(moon_altitude)
	_set_moon_color(moon_color)
	_set_moon_size(moon_size)
	
	_enable_set_moon_texture(enable_set_moon_texture)
	if enable_set_moon_texture:
		_set_moon_texture(moon_texture)
	
	_set_moon_resolution(moon_resolution)
	
	# Moon Light.
	_set_moon_light_path(moon_light_path)
	_set_moon_light_color(moon_light_color)
	_set_moon_light_energy(moon_light_energy)
	
	# Atmosphere
	_set_atm_quality(atm_quality)
	_set_atm_wavelenghts(atm_wavelenghts)
	_set_atm_darkness(atm_darkness)
	_set_atm_sun_intensity(atm_sun_intensity)
	_set_atm_day_tint(atm_day_tint)
	_set_atm_horizon_light_tint(atm_horizon_light_tint)
	_set_atm_enable_moon_scatter_mode(atm_enable_moon_scatter_mode)
	_set_atm_night_tint(atm_night_tint)
	_set_atm_level_params(atm_level_params)
	_set_atm_thickness(atm_thickness)
	_set_atm_mie(atm_mie)
	_set_atm_turbidity(atm_turbidity)
	_set_atm_sun_mie_tint(atm_sun_mie_tint)
	_set_atm_sun_mie_intensity(atm_sun_mie_intensity)
	_set_atm_sun_mie_anisotropy(atm_sun_mie_anisotropy)
	_set_atm_moon_mie_tint(atm_moon_mie_tint)
	_set_atm_moon_mie_intensity(atm_moon_mie_intensity)
	_set_atm_moon_mie_anisotropy(atm_moon_mie_anisotropy)
	
	# Fog.
	_set_fog_visible(fog_visible)
	_set_fog_atm_level_params_offset(fog_atm_level_params_offset)
	_set_fog_density(fog_density)
	_set_fog_rayleigh_depth(fog_rayleigh_depth)
	_set_fog_mie_depth(fog_mie_depth)
	_set_fog_falloff(fog_falloff)
	_set_fog_start(fog_start)
	_set_fog_end(fog_end)
	_set_fog_layers(fog_layers)
	_set_fog_render_priority(fog_render_priority)
	
	# Deep Space.
	_set_deep_space_euler(deep_space_euler)
	_set_deep_space_quat(deep_space_quat)
	_set_background_color(background_color)
	_set_set_background_texture(set_background_texture)
	
	if set_background_texture:
		_set_background_texture(background_texture)
	
	_set_stars_field_color(stars_field_color)
	_set_set_stars_field_texture(set_stars_field_texture)
	
	if set_stars_field_texture:
		_set_stars_field_texture(stars_field_texture)
	
	_set_stars_scintillation(stars_scintillation)
	_set_stars_scintillation_speed(stars_scintillation_speed)
	
	# Enviro.
	_set_enviro_container(enviro_container)
	_set_ambient_gradient(ambient_gradient)
	
	_set_enable_enviro_fog(enable_enviro_fog)
	_set_enviro_fog_gradient(enviro_fog_gradient)

func _set_color_correction_params() -> void:
	var param: Vector2
	param.x = tonemap
	param.y = exposure
	_resources.sky_material.set_shader_param(TOD_Const.P_COLOR_CORRECTION, param)
	_resources.fog_material.set_shader_param(TOD_Const.P_COLOR_CORRECTION, param)

func _build_moon() -> void:
	var moonInstancePath:= "MoonInstance"
	
	_moon_instance = get_node_or_null(moonInstancePath) as Viewport
	if _moon_instance == null:
		_moon_instance = _resources.moon_render.instance() as Viewport
		_moon_instance.name = moonInstancePath
		self.add_child(_moon_instance)
	_setup_moon_instance()

func _setup_moon_instance() -> void:
	assert(_moon_instance != null)
	_moon_instance_transform = _moon_instance.get_node_or_null("MoonTransform") as Spatial
	_moon_mesh_instance = _moon_instance_transform.get_node_or_null("Camera/Mesh") as MeshInstance
	_moon_mesh_instance.material_override = _resources.moon_material

func _force_setup_moon_instances() -> void:
	if check_moon_instance():
		_init_properties_ok = true
		_setup_moon_instance()

func _set_sun_coords() -> void:
	var azimuth: float = sun_azimuth * TOD_Math.DEG_TO_RAD
	var altitude: float = sun_altitude * TOD_Math.DEG_TO_RAD
	
	var finishSetSunPos:= false
	if !finishSetSunPos:
		_sun_transform.origin = TOD_Math.to_orbit(altitude, azimuth)
		finishSetSunPos = true
	
	if finishSetSunPos:
		_sun_transform = _sun_transform.looking_at(TOD_Const.APROXIMATE_ZERO_POSITION, Vector3.LEFT)
	
	_set_day_state(altitude)
	emit_signal("sun_direction_changed", get_sun_direction())
	emit_signal("sun_transform_changed", _sun_transform)
	
	_resources.moon_material.set_shader_param(TOD_Const.P_SUN_DIRECTION, get_sun_direction())
	_resources.near_space_material.set_shader_param(TOD_Const.P_SUN_DIRECTION, get_sun_direction())
	_resources.sky_material.set_shader_param(TOD_Const.P_SUN_DIRECTION, get_sun_direction())
	_resources.fog_material.set_shader_param(TOD_Const.P_SUN_DIRECTION, get_sun_direction())
	
	if _sun_light_ready:
		if _sun_light_node.light_energy > 0.0:
			_sun_light_node.transform = _sun_transform
	
	_sun_light_altitude_mult = TOD_Math.saturate(get_sun_direction().y)
	
	_set_night_intensity()
	_update_sun_light_color()
	_update_sun_light_energy()
	_update_moon_light_energy()
	_update_enviro()

func _set_moon_coords() -> void:
	var azimuth: float = moon_azimuth * TOD_Math.DEG_TO_RAD
	var altitude: float = moon_altitude * TOD_Math.DEG_TO_RAD
	var finish_set_pos:= false
	if !finish_set_pos:
		_moon_transform.origin = TOD_Math.to_orbit(altitude, azimuth)
		finish_set_pos = true
	
	if finish_set_pos:
		_moon_transform = _moon_transform.looking_at(TOD_Const.APROXIMATE_ZERO_POSITION, Vector3.LEFT)
	
	emit_signal("moon_direction_changed", get_moon_direction())
	emit_signal("moon_transform_changed", _moon_transform)
	
	if _init_properties_ok:
		assert(_moon_instance_transform != null)
		_moon_instance_transform.transform = _moon_transform
	
	_resources.near_space_material.set_shader_param(TOD_Const.P_MOON_DIRECTION, get_moon_direction())
	_resources.near_space_material.set_shader_param(TOD_Const.P_MOON_MATRIX, _moon_transform.basis.inverse())
	_resources.moon_material.set_shader_param(TOD_Const.P_SUN_DIRECTION, get_sun_direction())
	_resources.sky_material.set_shader_param(TOD_Const.P_MOON_DIRECTION, get_moon_direction())
	_resources.fog_material.set_shader_param(TOD_Const.P_MOON_DIRECTION, get_moon_direction())
	
	if _moon_light_ready:
		if _moon_light_node.light_energy > 0.0:
			_moon_light_node.transform = _moon_transform
	
	_moon_light_altitude_mult = TOD_Math.saturate(get_moon_direction().y)
	
	_set_night_intensity()
	_set_moon_light_color(moon_light_color)
	_update_moon_light_energy()
	_update_enviro()

func _set_day_state(v: float, threshold: float = 1.80) -> void:
	if abs(v) > threshold:
		emit_signal("is_day", false)
	else:
		emit_signal("is_day", true)
	_evaluate_light_enable()

func _set_beta_ray() -> void:
	var wls = TOD_AtmosphereLib.compute_wavelenghts(atm_wavelenghts, true)
	var betaRay = TOD_AtmosphereLib.compute_beta_ray(wls)
	_resources.sky_material.set_shader_param(TOD_Const.P_ATM_BETA_RAY, betaRay)
	_resources.fog_material.set_shader_param(TOD_Const.P_ATM_BETA_RAY, betaRay)

func _set_beta_mie() -> void:
	var bM = TOD_AtmosphereLib.compute_beta_mie(atm_mie, atm_turbidity)
	_resources.sky_material.set_shader_param(TOD_Const.P_ATM_BETA_MIE, bM)
	_resources.fog_material.set_shader_param(TOD_Const.P_ATM_BETA_MIE, bM)

func _set_night_intensity() -> void:
	var tint: Color = atm_night_tint * get_atm_night_intensity()
	_resources.sky_material.set_shader_param(TOD_Const.P_ATM_NIGHT_TINT, tint)
	_set_atm_moon_mie_intensity(atm_moon_mie_intensity)
	_resources.fog_material.set_shader_param(TOD_Const.P_ATM_NIGHT_TINT, tint * get_fog_atm_night_intensity())

func _evaluate_light_enable() -> void:
	if _sun_light_ready:
		_light_enable = _sun_light_node.light_energy > 0.0
		_sun_light_node.visible = _light_enable
	
	if _moon_light_ready:
		_moon_light_node.visible = !_light_enable

func _update_sun_light_color() -> void:
	if _sun_light_ready:
		_sun_light_node.light_color = TOD_Math.lerp_p_color(sun_horizon_light_color, sun_light_color, _sun_light_altitude_mult)

func _update_sun_light_energy() -> void:
	if _sun_light_ready:
		if sun_light_energy_curve != null:
			_sun_light_node.light_energy = sun_light_energy_curve.interpolate(TOD_Util.interpolate_by_above(get_sun_direction().y))
		else:
			_sun_light_node.light_energy = TOD_Math.lerp_p(0.0, sun_light_energy, _sun_light_altitude_mult)

func _update_moon_light_energy() -> void:
	if !_moon_light_ready:
		return
	
	var l = TOD_Math.lerp_p(0.0, moon_light_energy, _moon_light_altitude_mult)
	l *= get_atm_moon_phases_mul()
	
	var fade = (1.0 - get_sun_direction().y) + 0.5
	_moon_light_node.light_energy = l * _resources.sun_moon_curve_fade.interpolate_baked(fade)

func _update_enviro() -> void:
	if _enviro != null:
		var sAlt: float = get_sun_direction().y
		if ambient_gradient != null:
			var intensity: float = TOD_Math.lerp_p(1.0, get_atm_night_intensity(), TOD_Math.saturate(-sAlt + 0.60))
			_enviro.ambient_light_color = ambient_gradient.interpolate(
				TOD_Util.interpolate_full(sAlt)) * intensity
		else:
			var a = TOD_Math.saturate(1.0 - sAlt)
			var b = TOD_Math.saturate(-sAlt + 0.60)
			
			var colA:= TOD_Math.lerp_p_color(atm_day_tint*0.5, atm_horizon_light_tint, a)
			var colB:= TOD_Math.lerp_p_color(colA, atm_night_tint * get_atm_night_intensity(), b)
			
			_enviro.ambient_light_color = colB
		
		# Fog.
		if enable_enviro_fog && enviro_fog_gradient != null:
			var intensity: float = TOD_Math.lerp_p(1.0, get_atm_night_intensity(), TOD_Math.saturate(-sAlt + 0.60))
			
			_enviro.fog_color = enviro_fog_gradient.interpolate(
				TOD_Util.interpolate_full(sAlt))
			_enviro.fog_color.r *= intensity
			_enviro.fog_color.g *= intensity
			_enviro.fog_color.b *= intensity

# **** Editor Properties ****
func _get_property_list() -> Array:
	var ret: Array
	ret.push_back({name = "Skydome", type=TYPE_NIL, usage=PROPERTY_USAGE_CATEGORY})
	
	# Global.
	ret.push_back({name = "Global", type=TYPE_NIL, usage=PROPERTY_USAGE_GROUP})
	ret.push_back({name = "sky_visible", type=TYPE_BOOL})
	ret.push_back({name = "tonemap", type=TYPE_REAL, hint=PROPERTY_HINT_RANGE, hint_string="0.0, 1.0"})
	ret.push_back({name = "exposure", type=TYPE_REAL})
	ret.push_back({name = "horizon_level", type=TYPE_REAL})
	ret.push_back({name = "ground_color", type=TYPE_COLOR})
	
	ret.push_back({name = "near_space_layers", type=TYPE_INT, hint=PROPERTY_HINT_LAYERS_3D_RENDER})
	ret.push_back({name = "sky_layers", type=TYPE_INT, hint=PROPERTY_HINT_LAYERS_3D_RENDER})
	ret.push_back({name = "sky_render_priority", type=TYPE_INT})
	
	# Sun.
	ret.push_back({name = "Sun", type=TYPE_NIL, usage=PROPERTY_USAGE_GROUP})
	ret.push_back({name = "sun_altitude", type=TYPE_REAL, hint=PROPERTY_HINT_RANGE, hint_string="-180.0, 180.0"})
	ret.push_back({name = "sun_azimuth", type=TYPE_REAL, hint=PROPERTY_HINT_RANGE, hint_string="-180.0, 180.0"})
	ret.push_back({name = "sun_disk_color", type=TYPE_COLOR})
	ret.push_back({name = "sun_disk_intensity", type=TYPE_REAL, hint=PROPERTY_HINT_RANGE, hint_string="0.0, 50.0"}) # Clamped 2.0 for prevent reflection probe artifacts.
	ret.push_back({name = "sun_disk_size", type=TYPE_REAL, hint=PROPERTY_HINT_RANGE, hint_string="0.0, 0.5"})
	
	# Sun Light.
	ret.push_back({name = "Sun Light", type=TYPE_NIL, usage=PROPERTY_USAGE_GROUP})
	
	ret.push_back({name = "sun_light_color", type=TYPE_COLOR})
	ret.push_back({name = "sun_horizon_light_color", type=TYPE_COLOR})
	ret.push_back({name = "sun_light_energy", type=TYPE_REAL})
	ret.push_back({name = "sun_light_energy_curve", type=TYPE_OBJECT, hint=PROPERTY_HINT_RESOURCE_TYPE, hint_string="Curve"})
	ret.push_back({name = "sun_light_path", type=TYPE_NODE_PATH})
	
	# Moon.
	ret.push_back({name = "Moon", type=TYPE_NIL, usage=PROPERTY_USAGE_GROUP})
	ret.push_back({name = "moon_altitude", type=TYPE_REAL, hint=PROPERTY_HINT_RANGE, hint_string = "-180.0, 180.0"})
	ret.push_back({name = "moon_azimuth", type=TYPE_REAL, hint=PROPERTY_HINT_RANGE, hint_string="-180.0, 180.0"})
	ret.push_back({name = "moon_color", type=TYPE_COLOR})
	ret.push_back({name = "moon_size", type=TYPE_REAL})
	
	ret.push_back({name = "enable_set_moon_texture", type=TYPE_BOOL})
	if enable_set_moon_texture:
		ret.push_back({name = "moon_texture", type=TYPE_OBJECT, hint=PROPERTY_HINT_FILE, hint_string="Texture"})
	
	ret.push_back({name = "moon_resolution", type=TYPE_INT, hint=PROPERTY_HINT_ENUM, hint_string="64, 128, 256, 512, 1024"})
	
	ret.push_back({name = "Moon Light", type=TYPE_NIL, usage=PROPERTY_USAGE_GROUP})
	ret.push_back({name = "moon_light_path", type=TYPE_NODE_PATH})
	ret.push_back({name = "moon_light_color", type=TYPE_COLOR})
	ret.push_back({name = "moon_light_energy", type=TYPE_REAL})
	
	# Atmosphere.
	ret.push_back({name = "Atmosphere", type=TYPE_NIL, usage=PROPERTY_USAGE_GROUP})
	ret.push_back({name = "atm_quality", type=TYPE_INT, hint=PROPERTY_HINT_ENUM, hint_string="PerPixel, PerVertex"})
	ret.push_back({name = "atm_wavelenghts", type=TYPE_VECTOR3})
	ret.push_back({name = "atm_darkness", type=TYPE_REAL, hint=PROPERTY_HINT_RANGE, hint_string="0.0, 1.0"})
	ret.push_back({name = "atm_sun_intensity", type=TYPE_REAL})
	ret.push_back({name = "atm_day_tint", type=TYPE_COLOR})
	ret.push_back({name = "atm_horizon_light_tint", type=TYPE_COLOR})
	ret.push_back({name = "atm_enable_moon_scatter_mode", type=TYPE_BOOL})
	ret.push_back({name = "atm_night_tint", type=TYPE_COLOR})
	ret.push_back({name = "atm_level_params", type=TYPE_VECTOR3})
	ret.push_back({name = "atm_thickness", type=TYPE_REAL, hint=PROPERTY_HINT_RANGE, hint_string="0.0, 100.0"})
	ret.push_back({name = "atm_mie", type=TYPE_REAL})
	ret.push_back({name = "atm_turbidity", type=TYPE_REAL})
	ret.push_back({name = "atm_sun_mie_tint", type=TYPE_COLOR})
	ret.push_back({name = "atm_sun_mie_intensity", type=TYPE_REAL})
	ret.push_back({name = "atm_sun_mie_anisotropy", type=TYPE_REAL, hint=PROPERTY_HINT_RANGE, hint_string="0.0, 0.9999999"})
	ret.push_back({name = "atm_moon_mie_tint", type=TYPE_COLOR})
	ret.push_back({name = "atm_moon_mie_intensity", type=TYPE_REAL})
	ret.push_back({name = "atm_moon_mie_anisotropy", type=TYPE_REAL, hint=PROPERTY_HINT_RANGE, hint_string="0.0, 0.9999999"})
	
	ret.push_back({name = "Atmospheric Fog", type=TYPE_NIL, usage=PROPERTY_USAGE_GROUP})
	ret.push_back({name = "fog_visible", type=TYPE_BOOL})
	ret.push_back({name = "fog_atm_level_params_offset", type=TYPE_VECTOR3})
	ret.push_back({name = "fog_density", type=TYPE_REAL, hint=PROPERTY_HINT_EXP_EASING, hint_string="0.0, 1.0"})
	ret.push_back({name = "fog_rayleigh_depth", type=TYPE_REAL, hint=PROPERTY_HINT_EXP_EASING, hint_string="0.0, 1.0"})
	ret.push_back({name = "fog_mie_depth", type= TYPE_REAL, hint=PROPERTY_HINT_EXP_EASING, hint_string="0.0, 1.0"})
	ret.push_back({name = "fog_falloff", type=TYPE_REAL, hint=PROPERTY_HINT_RANGE, hint_string="0.0, 10.0"})
	ret.push_back({name = "fog_start", type=TYPE_REAL, hint=PROPERTY_HINT_RANGE, hint_string="0.0, 8500.0"})
	ret.push_back({name = "fog_end", type=TYPE_REAL, hint=PROPERTY_HINT_RANGE, hint_string="0.0, 8500.0"})
	ret.push_back({name = "fog_layers", type=TYPE_INT, hint=PROPERTY_HINT_LAYERS_3D_RENDER})
	ret.push_back({name = "fog_render_priority", type=TYPE_INT})
	
	# Deep Space.
	ret.push_back({name = "DeepSpace", type=TYPE_NIL, usage=PROPERTY_USAGE_GROUP})
	ret.push_back({name = "deep_space_euler", type=TYPE_VECTOR3})
	ret.push_back({name = "background_color", type=TYPE_COLOR})
	ret.push_back({name = "set_background_texture", type=TYPE_BOOL})
	
	if set_background_texture:
		ret.push_back({name = "background_texture", type=TYPE_OBJECT, hint=PROPERTY_HINT_RESOURCE_TYPE, hint_string="Texture"})
	
	ret.push_back({name = "stars_field_color", type=TYPE_COLOR})
	ret.push_back({name = "set_stars_field_texture", type=TYPE_BOOL})
	if set_stars_field_texture:
		ret.push_back({name = "stars_field_texture", type=TYPE_OBJECT, hint=PROPERTY_HINT_RESOURCE_TYPE, hint_string="Texture"})
	ret.push_back({name = "stars_scintillation", type=TYPE_REAL, hint=PROPERTY_HINT_RANGE, hint_string="0.0, 1.0"})
	ret.push_back({name = "stars_scintillation_speed", type=TYPE_REAL})
	
	# Enviro.
	ret.push_back({name = "Environment", type=TYPE_NIL, usage=PROPERTY_USAGE_GROUP})
	ret.push_back({name = "enviro_container", type=TYPE_NODE_PATH})
	ret.push_back({name = "ambient_gradient", type=TYPE_OBJECT, hint=PROPERTY_HINT_RESOURCE_TYPE, hint_string="Gradient"})
	
	ret.push_back({name = "enable_enviro_fog", type=TYPE_BOOL})
	
	if enable_enviro_fog:
		ret.push_back({name = "enviro_fog_gradient", type=TYPE_OBJECT, hint=PROPERTY_HINT_RESOURCE_TYPE, hint_string="Gradient"})
	
	
	return ret
