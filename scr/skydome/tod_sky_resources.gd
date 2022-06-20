tool
class_name TOD_SkyResources extends Resource
# Description:
# - Resources for skydome.
# License:
# - J. Cuéllar 2022 MIT License
# - See: LICENSE File.

# Meshes.
var full_screen_quad:= QuadMesh.new()
var dome_mesh:= SphereMesh.new()

# Materials.
var sky_material:= ShaderMaterial.new()
var near_space_material:= ShaderMaterial.new()
var moon_material:= ShaderMaterial.new()
var fog_material:= ShaderMaterial.new()

# Shaders.
const sky_shader: Shader = preload("res://addons/jc.godot3.time-of-day/scr/shaders/sky.shader")
const per_vertex_sky_shader: Shader = preload("res://addons/jc.godot3.time-of-day/scr/shaders/per_vertex_sky.shader")
const near_space_shader: Shader = preload("res://addons/jc.godot3.time-of-day/scr/shaders/near_space.shader")
const moon_shader: Shader = preload("res://addons/jc.godot3.time-of-day/scr/shaders/moon.shader")
const fog_shader: Shader = preload("res://addons/jc.godot3.time-of-day/scr/shaders/atmospheric_fog.shader")

# Scenes.
const moon_render: PackedScene = preload("res://addons/jc.godot3.time-of-day/content/resources/moon/MoonRender.tscn")

# Textures.
const moon_texture: Texture = preload("res://addons/jc.godot3.time-of-day/content/graphics/third-party/textures/moon-map/MoonMap.png")
const background_texture: Texture = preload("res://addons/jc.godot3.time-of-day/content/graphics/third-party/textures/milky-way/Milkyway.jpg")
const stars_field_texture: Texture = preload("res://addons/jc.godot3.time-of-day/content/graphics/third-party/textures/milky-way/StarField.jpg")
const stars_field_noise: Texture = preload("res://addons/jc.godot3.time-of-day/content/graphics/noise.jpg")

const sun_moon_curve_fade: Curve = preload("res://addons/jc.godot3.time-of-day/content/resources/SunMoonLightFade.tres")

func _init() -> void:
	full_screen_quad.size = 2.0 * Vector2.ONE

func setup_shaders() -> void:
	sky_material.shader = sky_shader
	near_space_material.shader = near_space_shader
	fog_material.shader = fog_shader

func setup_render_priority(value: int) -> void:
	sky_material.render_priority = value
	near_space_material.render_priority = value + 1

func setup_fog_render_priority(value: int) -> void:
	fog_material.render_priority = value

func setup_moon_resources() -> void:
	moon_material.shader = moon_shader
	moon_material.setup_local_to_scene()

func set_atmosphere_quality(quality: int) -> void:
	match(quality):
		TOD_Enums.AtmosphereQuality.PerPixel:
			dome_mesh.radial_segments = 16
			dome_mesh.rings = 8
			sky_material.shader = sky_shader
		TOD_Enums.AtmosphereQuality.PerVertex:
			dome_mesh.radial_segments = 64
			dome_mesh.rings = 64
			sky_material.shader = per_vertex_sky_shader

