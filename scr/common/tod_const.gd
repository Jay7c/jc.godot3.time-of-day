class_name TOD_Const
# Description:
# - Const for TOD.
# License:
# - J. Cuéllar 2022 MIT License
# - See: LICENSE File.

# Transform.
const DEFAULT_BASIS:= Basis(
	Vector3(1.0, 0.0, 0.0), Vector3(0.0, 1.0, 0.0), Vector3(0.0, 0.0, 1.0)
)

const APROXIMATE_ZERO_POSITION:= Vector3(0.0000001, 0.0000001, 0.0000001)

# Rendering.
const MAX_EXTRA_CULL_MARGIN: float = 16384.0

# Global.
const P_HORIZON_LEVEL:= "_HorizonLevel"
const P_GROUND_COLOR:= "_GroundColor"
const P_TEXTURE:= "_Texture"
const P_NOISE_TEX:= "_NoiseTex"
const P_COLOR_CORRECTION:= "_ColorCorrection"

# Sun.
const P_SUN_DISK_COLOR:= "_SunDiskColor"
const P_SUN_DISK_INTENSITY:= "_SunDiskIntensity"
const P_SUN_DISK_SIZE:= "_SunDiskSize"
const P_SUN_DIRECTION:= "_SunDirection"

# Moon.
const P_MOON_COLOR:= "_MoonColor"
const P_MOON_SIZE:= "_MoonSize"
const P_MOON_TEXTURE:= "_MoonTexture"
const P_MOON_DIRECTION:= "_MoonDirection"
const P_MOON_MATRIX:= "_MoonMatrix"

# Atmosphere.
const P_ATM_DARKNESS:= "_AtmDarkness"
const P_ATM_SUN_INTENSITY:= "_AtmSunIntensity"
const P_ATM_DAY_TINT:= "_AtmDayTint"
const P_ATM_HORIZON_LIGHT_TINT:= "_AtmHorizonLightTint"
const P_ATM_LEVEL_PARAMS:= "_AtmLevelParams"
const P_ATM_THICKNESS:= "_AtmThickness"
const P_ATM_SUN_MIE_TINT:= "_AtmSunMieTint"
const P_ATM_SUN_MIE_INTENSITY:= "_AtmSunMieIntensity"
const P_ATM_SUN_PARTIAL_MIE_PHASE:= "_AtmSunPartialMiePhase"
const P_ATM_MOON_MIE_TINT:= "_AtmMoonMieTint"
const P_ATM_MOON_MIE_INTENSITY:= "_AtmMoonMieIntensity"
const P_ATM_MOON_PARTIAL_MIE_PHASE:= "_AtmMoonPartialMiePhase"
const P_ATM_BETA_RAY:= "_AtmBetaRay"
const P_ATM_BETA_MIE:= "_AtmBetaMie"
const P_ATM_NIGHT_TINT:= "_AtmNightTint"

# Fog.
const P_FOG_DENSITY:= "_FogDensity"
const P_FOG_START:= "_FogStart"
const P_FOG_END:= "_FogEnd"
const P_FOG_RAYLEIGH_DEPTH:= "_FogRayleighDepth"
const P_FOG_MIE_DEPTH:= "_FogMieDepth"
const P_FOG_FALLOFF:= "_FogFalloff"

# Deep Space.
const P_DEEP_SPACE_MATRIX:= "_DeepSpaceMatrix"
const P_BACKGROUND_COLOR:= "_BackgroundColor"
const P_BACKGROUND_TEXTURE:= "_BackgroundTexture"

# Near Space.
const P_STARS_FIELD_COLOR:= "_StarsFieldTexture"
const P_STARS_FIELD_SCINTILLATION:= "_StarsScintillation"
const P_STARS_FIELD_SCONTILLATION_SPEED:= "_StarsScintillationSpeed"
