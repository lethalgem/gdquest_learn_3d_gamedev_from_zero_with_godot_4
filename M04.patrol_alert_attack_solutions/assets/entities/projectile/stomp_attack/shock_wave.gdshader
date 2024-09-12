shader_type spatial;
render_mode cull_disabled;

uniform vec3 albedo : source_color;
uniform float alpha : hint_range(0.0, 1.0, 0.1);
uniform float offset = 0.0;
uniform sampler2D noise_sampler : filter_linear_mipmap, repeat_enable;

void fragment() {
	float noise = texture(noise_sampler, UV * vec2(1.0, 1.0) + vec2(0.0, offset)).x;
	ALBEDO = albedo;
	EMISSION = ALBEDO;
	ALPHA *= alpha * step(0.2, noise * UV.y);
}