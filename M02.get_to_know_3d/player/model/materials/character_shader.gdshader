shader_type spatial;

uniform sampler2D albedo_sampler : filter_linear_mipmap, source_color, repeat_disable;
uniform sampler2D normal_sampler : filter_linear_mipmap, hint_normal, repeat_disable;

#include "res://shared/shaders/fresnel.gdshaderinc"

void fragment() {
	ALBEDO = texture(albedo_sampler, UV).rgb;
	NORMAL_MAP = texture(normal_sampler, UV).xyz;
	ROUGHNESS = 0.65;
	EMISSION = ALBEDO * step(0.5, fresnel(1.0, NORMAL, VIEW)) * 0.5;
}