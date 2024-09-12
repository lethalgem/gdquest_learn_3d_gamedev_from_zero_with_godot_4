shader_type spatial;

#include "res://shared/shaders/fresnel.gdshaderinc"

void fragment() {
	float f = fresnel(1.0, NORMAL, VIEW);
	ROUGHNESS = 0.15;
	SPECULAR = 1.0;
	ALBEDO = vec3(1.0);
	float m = min(1.0, step(0.5, f) + f * 0.5);
	ALPHA = m;
	EMISSION = ALBEDO * m * 0.45;
}