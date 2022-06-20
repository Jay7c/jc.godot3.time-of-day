shader_type spatial;
render_mode unshaded, blend_mix, depth_draw_never, cull_front, skip_vertex_transform;

uniform vec3 _SunDirection;
uniform vec3 _MoonDirection;
uniform float _Coverage;
uniform float _Thickness;
uniform float _Absorption;
uniform float _NoiseFreq;
//uniform float _clouds_sky_tint_fade = 1.0;
uniform float _Intensity;
uniform float _Size;
uniform float _OffsetSpeed;
uniform vec3 _Offset;
uniform sampler2D _Noise;

uniform vec4 _DayColor: hint_color;
uniform vec4 _HorizonColor: hint_color;
uniform vec4 _NightColor: hint_color;

const int kCLOUDS_STEP = 10;

uniform vec3 _PartialMiePhase;
uniform float _MieIntensity;
uniform vec4 _MieTint = vec4(1.0);
//uniform vec4 _MoonMieTint: hint_color = vec4(1.0);

uniform float _HorizonLevel;

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

float Saturate(float value){
	return clamp(value, 0.0, 1.0);
}

vec3 SaturateRGB(vec3 value){
	return clamp(value.rgb, 0.0, 1.0);
}

float Pow3(float real){
	return real * real * real;
}

float NoiseClouds(vec3 p){
	vec3 pos = vec3(p * 0.01);
	pos.z *= 256.0;
	vec2 offset = vec2(0.317, 0.123);
	vec4 uv= vec4(0.0);
	uv.xy = pos.xy + offset * floor(pos.z);
	uv.zw = uv.xy + offset;
	float x1 = textureLod(_Noise, uv.xy, 0.0).r;
	float x2 = textureLod(_Noise, uv.zw, 0.0).r;
	return mix(x1, x2, fract(pos.z));
}

float CloudsFBM(vec3 p, float l){
	float ret;
	ret = 0.51749673 * NoiseClouds(p);  
	p *= l;
	ret += 0.25584929 * NoiseClouds(p); 
	p *= l; 
	ret += 0.12527603 * NoiseClouds(p); 
	p *= l;
	ret += 0.06255931 * NoiseClouds(p);
	return ret;
}

float NoiseCloudsFBM(vec3 p, float freq){
	return CloudsFBM(p, freq);
}

float Remap(float value, float fromMin, float fromMax, float toMin, float toMax){
	return toMin + (value - fromMin) * (toMax - toMin) / (fromMax - fromMin);
}

float CloudsDensity(vec3 p, vec3 offset, float t){
	vec3 pos = p * 0.0212242 + offset;
	float dens = NoiseCloudsFBM(pos, _NoiseFreq);
	dens += dens;
	
	float cov = 1.0-_Coverage;
	cov = smoothstep(0.00, (cov * 3.5) + t, dens);
	dens *= cov;
	dens = Remap(dens, 1.0-cov, 1.0, 0.0, 1.0); 
	
	return Saturate(dens);
}

bool IntersectSphere(float r, vec3 origin, vec3 dir, out float t, out vec3 nrm)
{
	origin += vec3(0.0, 450.0, 0.0);
	float a = dot(dir, dir);
	float b = 2.0 * dot(origin, dir);
	float c = dot(origin, origin) - r * r;
	float d = b * b - 4.0 * a * c;
	if(d < 0.0) return false;
	
	d = sqrt(d);
	a *= 2.0;
	float t1 = 0.5 * (-b + d);
	float t2 = 0.5 * (-b - d);
	
	if(t1<0.0) t1 = t2;
	if(t2 < 0.0) t2 = t1;
	t1 = min(t1, t2);
	
	if(t1 < 0.0) return false;
	nrm = origin + t1 * dir;
	t = t1;
	
	return true;
}

float MiePhase(float mu, vec3 partial){
	return kPI4 * (partial.x) * (pow(partial.y - partial.z * mu, -1.5));
}

vec4 RenderClouds(vec3 ro, vec3 rd, float tm, float am){
	vec4 ret;
	vec3 wind = _Offset * (tm * _OffsetSpeed);
    vec3 n; float tt; float a = 0.0;
    if(IntersectSphere(500, ro, rd, tt, n))
	{
		float marchStep = float(kCLOUDS_STEP) * _Thickness;
		vec3 dirStep = rd / rd.y * marchStep;
		vec3 pos = n * _Size;
		
		vec2 mu = vec2(dot(_SunDirection, rd), dot(_MoonDirection, rd));
		float mph = ((MiePhase(mu.x, _PartialMiePhase)) +
		MiePhase(mu.y, _PartialMiePhase) * am);
		
		vec4 t = vec4(1.0);
		t.rgb += (mph * _MieIntensity);
		
		for(int i = 0; i < kCLOUDS_STEP; i++)
		{
			float h = float(i) * 0.1; // / float(kCLOUDS_STEP);
			float density = CloudsDensity(pos, wind, h);
			float sh = Saturate(exp(-_Absorption * density * marchStep));
			t *= sh;
			ret += (t * (exp(h) * 0.571428571) * density * marchStep);
			a += (1.0 - sh) * (1.0 - a);
			pos += dirStep;
		}
		return vec4(ret.rgb * _Intensity, a);
	}
	return vec4(ret.rgb * _Intensity, a);
}


varying vec4 world_pos;
varying vec4 moon_coords;
varying vec3 deep_space_coords;
varying vec4 angle_mult;

void vertex(){
	vec4 vert = vec4(VERTEX, 0.0);
	//vert.y += _HorizonLevel;
	
	POSITION =  PROJECTION_MATRIX * INV_CAMERA_MATRIX * WORLD_MATRIX * vert;
	POSITION.z = POSITION.w;
	
	world_pos = (WORLD_MATRIX * vert);
	angle_mult.x = Saturate(1.0 - _SunDirection.y);
	angle_mult.y = Saturate(_SunDirection.y + 0.45);
	angle_mult.z = Saturate(-_SunDirection.y + 0.30);
	angle_mult.w = Saturate(-_SunDirection.y + 0.60);
}

void fragment(){
	vec3 ray = normalize(world_pos).xyz;
	float horizonBlend = Saturate((ray.y+0.01) * 50.0);
	
	vec4 clouds = RenderClouds(vec3(0.0, -_HorizonLevel, 0.0), ray, TIME, angle_mult.z);
	clouds.a = Saturate(clouds.a);
	clouds.rgb *= mix(mix(_DayColor.rgb, _HorizonColor.rgb, angle_mult.x), 
		_NightColor.rgb, angle_mult.w);
	clouds.a = mix(0.0, clouds.a, horizonBlend);
	
	ALBEDO = clouds.rgb;
	ALPHA = Pow3(clouds.a);
	DEPTH = 1.0;
}