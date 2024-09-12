shader_type spatial;

uniform vec3 base_color : source_color;
uniform vec3 edge_color : source_color;

#include "res://shared/shaders/fresnel.gdshaderinc"

void fragment(){
	float f = step(0.5, fresnel(1.0, NORMAL, VIEW));
	ALBEDO = mix(base_color, edge_color, f);
	EMISSION = ALBEDO * 1.4;
	ROUGHNESS = 0.0;
	SPECULAR = 0.0;
}