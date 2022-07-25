// Description:
// - Fog atmosphere tinted.
// License:
// - J. Cuéllar 2022 MIT License
// - See: LICENSE File.
shader_type spatial;
render_mode blend_mix, depth_draw_never, cull_disabled, unshaded, async_visible;

// Params.
//------------------------------------------------------------------------------
uniform vec2 _ColorCorrection;
uniform float _HorizonLevel;

// Directions.
uniform vec3 _SunDirection;
uniform vec3 _MoonDirection;

// Rayleigh.
uniform float _AtmDarkness;
uniform float _AtmSunIntensity;
uniform vec4 _AtmDayTint: hint_color;
uniform vec4 _AtmHorizonLightTint: hint_color;
uniform vec4 _AtmNightTint: hint_color;
uniform vec3 _AtmLevelParams;
uniform float _AtmThickness;
uniform vec3 _AtmBetaRay;

// Mie.
uniform vec4 _AtmSunMieTint: hint_color;
uniform float _AtmSunMieIntensity;
uniform vec3 _AtmSunPartialMiePhase;

uniform vec4 _AtmMoonMieTint: hint_color;
uniform float _AtmMoonMieIntensity;
uniform vec3 _AtmMoonPartialMiePhase;
uniform vec3 _AtmBetaMie;

const float RAYLEIGH_ZENITH_LENGTH = 8.4e3;
const float MIE_ZENITH_LENGTH = 1.25e3;

// Fog.
uniform float _FogDensity;
uniform float _FogFalloff;
uniform float _FogStart;
uniform float _FogEnd;

uniform float _FogRayleighDepth;
uniform float _FogMieDepth;

// Lib.
//------------------------------------------------------------------------------
const float kPI          = 3.1415927f;
const float kINV_PI      = 0.3183098f;
const float kHALF_PI     = 1.5707963f;
const float kINV_HALF_PI = 0.6366198f;
const float kQRT_PI      = 0.7853982f;
const float kINV_QRT_PI  = 1.2732395f;
const float kPI4         = 12.5663706f;
const float kINV_PI4     = 0.0795775f;
const float k3PI16       = 0.1193662f;
const float kTAU         = 6.2831853f;
const float kINV_TAU     = 0.1591549f;
const float kE           = 2.7182818f;

float Saturate(float val){
	return clamp(val, 0.0, 1.0);
}

vec3 SaturateRGB(vec3 val){
	return clamp(val, 0.0, 1.0);
}

vec3 ContrastLevel(vec3 val, float level){
	return mix(val, val * val * val, level);
}

vec3 TonemapPhoto(vec3 col, float exposure, float level){
	col.rgb *= exposure;
	return mix(col.rgb, 1.0 - exp2(-col.rgb), level);
}

// Functions.
//------------------------------------------------------------------------------
float RayleighPhase(float mu){
	return k3PI16 * (1.0 + mu * mu);
}

float MiePhase(float mu, vec3 partial){
	return kPI4 * partial.x * (pow(partial.y - partial.z * mu, -1.5));
}

// Simplifield for more performance.
void SimpleOpticalDepth(float y, out float sr, out float sm){
	y = max(0.03, y + 0.03) + _AtmLevelParams.y;
	y = 1.0 / (y * _AtmLevelParams.x);
	sr = y * RAYLEIGH_ZENITH_LENGTH;
	sm = y * MIE_ZENITH_LENGTH;
}

// ṔPaper based.
void OpticalDepth(float y, out float sr, out float sm){
	y = max(0.0, y);
	y = Saturate(y * _AtmLevelParams.x);
	
	float zenith = acos(y);
	zenith = cos(zenith) + 0.15 * pow(93.885 - ((zenith * 180.0) / kPI), -1.253);
	zenith = 1.0 / (zenith + _AtmLevelParams.y);
	
	sr = zenith * RAYLEIGH_ZENITH_LENGTH;
	sm = zenith * MIE_ZENITH_LENGTH;
}

vec3 AtmosphericScattering(float sr, float sm, vec2 mu, vec3 mult, float depth){
	vec3 betaMie = _AtmBetaMie;
	vec3 betaRay = _AtmBetaRay * _AtmThickness;
	
	vec3 extcFactor = SaturateRGB(exp(-(betaRay * sr + betaMie * sm)));
	
	float extcFF = mix(Saturate(_AtmThickness * 0.5), 1.0, mult.x);
	vec3 finalExtcFactor = mix(1.0 - extcFactor, (1.0 - extcFactor) * extcFactor, extcFF);
	
	float rayleighPhase = RayleighPhase(mu.x);
	vec3 BRT = betaRay * rayleighPhase * Saturate(depth * _FogRayleighDepth);
	vec3 BMT = betaMie * MiePhase(mu.x, _AtmSunPartialMiePhase);
	BMT *= _AtmSunMieIntensity * _AtmSunMieTint.rgb * Saturate(depth * _FogMieDepth);
	
	vec3 BRMT = (BRT + BMT) / (betaRay + betaMie);
	vec3 scatter = _AtmSunIntensity * (BRMT * finalExtcFactor) * _AtmDayTint.rgb * mult.y;
	scatter = mix(scatter, scatter * (1.0 - extcFactor), _AtmDarkness);
	
	vec3 lcol = mix(_AtmDayTint.rgb, _AtmHorizonLightTint.rgb, mult.x);
	vec3 nscatter = (1.0 - extcFactor) * _AtmNightTint.rgb * Saturate(depth * _FogRayleighDepth);
	nscatter += MiePhase(mu.y, _AtmMoonPartialMiePhase) * 
		_AtmMoonMieTint.rgb * _AtmMoonMieIntensity * 0.005 * Saturate(depth * _FogMieDepth);
	
	return (scatter * lcol) + nscatter;
}

// Fog
float FogExp(float depth, float density){
	return 1.0 - Saturate(exp2(-depth * density));
}

float FogFalloff(float y, float zeroLevel, float falloff){
	return Saturate(exp(-(y + zeroLevel) * falloff));
}

float FogDistance(float depth){
	float d = depth;
	d = (_FogEnd - d) / (_FogEnd - _FogStart);
	return Saturate(1.0 - d);
}

vec3 Mul43(mat4 m, vec4 v){
	return (m * v).xyz;
}

vec4 Mul44(mat4 m, vec4 v){
	return m * v;
}

void ComputeCoords(vec2 uv, float depth, mat4 camMat, mat4 invProjMat, 
	out vec3 viewDir, out vec3 worldPos){
	
	vec3 ndc = vec3(uv * 2.0 - 1.0, depth);
	
	// ViewDir
	vec4 view = invProjMat * vec4(ndc, 1.0);
	viewDir = view.xyz / view.w;
	
	// worldPos.
	view = camMat * view;
	view.xyz /= view.w;
	view.xyz -= (camMat * vec4(0.0001, 0.0, 0.0, 1.0)).xyz;
	worldPos = view.xyz;
}


varying mat4 v_camera_matrix;
varying vec4 v_angle_mult;

void vertex(){
	POSITION = vec4(VERTEX.xy, -1.0, 1.0);
	//POSITION = PROJECTION_MATRIX * MODELVIEW_MATRIX * vec4(VERTEX, 1.0);
	v_angle_mult.x = Saturate(1.0 - _SunDirection.y);
	v_angle_mult.y = Saturate(_SunDirection.y + 0.45);
	v_angle_mult.z = Saturate(-_SunDirection.y + 0.30);
	v_angle_mult.w = Saturate(_SunDirection.y);
	v_camera_matrix = CAMERA_MATRIX;
}

void fragment(){
	float depthRaw = texture(DEPTH_TEXTURE, SCREEN_UV).r;
	vec3 view; vec3 worldPos; float half; 
	ComputeCoords(SCREEN_UV, depthRaw, v_camera_matrix, INV_PROJECTION_MATRIX, view, worldPos);
	worldPos = normalize(worldPos);
	
	vec3 cameraPos = (CAMERA_MATRIX * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
	vec4 viewVector = Mul44(INV_PROJECTION_MATRIX, vec4(SCREEN_UV * 2.0 - 1.0, 1.0, 1.0));
	float linearDepth = -view.z;

	float fogFactor =  FogExp(linearDepth, _FogDensity);
	fogFactor *=  FogFalloff(worldPos.y, 0.0, _FogFalloff);
	fogFactor *= FogDistance(linearDepth);
	
	vec2 mu = vec2(dot(_SunDirection, worldPos), dot(_MoonDirection, worldPos));
	float sr; float sm; SimpleOpticalDepth(worldPos.y + _AtmLevelParams.z, sr, sm);
	vec3 scatter = AtmosphericScattering(sr, sm, mu.xy,v_angle_mult.xyz, linearDepth);
	
	vec3 tint =  scatter;
	vec4 fogColor = vec4(tint.rgb, fogFactor);
	fogColor = vec4((fogColor.rgb), Saturate(fogColor.a));
	fogColor.rgb = TonemapPhoto(fogColor.rgb, _ColorCorrection.y, _ColorCorrection.x);
	
	ALBEDO = fogColor.rgb;
	//ALPHA = fogColor.a;
	ALPHA = (depthRaw) < 0.999999999999 ? fogColor.a: 0.0; // Exclude sky.
}
