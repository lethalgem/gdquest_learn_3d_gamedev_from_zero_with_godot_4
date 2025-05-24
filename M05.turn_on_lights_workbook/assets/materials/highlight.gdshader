shader_type spatial;
render_mode cull_disabled, unshaded;

uniform vec4 outline_color: source_color;
uniform float outline_width = 0.1;
uniform float stripe_frequency = 4.0;
uniform float stripe_animation_speed = 1.0;
uniform float alpha: hint_range(0.0, 1.0, 0.1) = 1.0;

varying vec3 world_position;

void vertex() {
    VERTEX += NORMAL * outline_width;
    world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
    // Use Y world position to create a vertical pattern and make the stripe
    // size consistent across all game objects
    float wave = (1.0 + sin(world_position.y * stripe_frequency + TIME * stripe_animation_speed)) / 2.0;
    ALBEDO = outline_color.rgb;
    ALPHA = (step(wave, 0.6) * 0.4 + (1.0 - float(FRONT_FACING))) * alpha;
}
