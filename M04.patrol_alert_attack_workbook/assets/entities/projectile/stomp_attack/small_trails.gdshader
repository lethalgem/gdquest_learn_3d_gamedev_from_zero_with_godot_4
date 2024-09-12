shader_type spatial;
render_mode cull_disabled;

void fragment() {
	ALBEDO = COLOR.rgb;
	EMISSION = COLOR.rgb * 1.2;
	ALPHA *= COLOR.a * (1.0 - UV.y);
}
