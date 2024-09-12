shader_type particles;
render_mode collision_use_scale;

uniform sampler2D scale_curve : repeat_disable;

float rand_from_seed(in uint seed) {
	int k;
	int s = int(seed);
	if (s == 0) s = 305420679;
	k = s / 127773;
	s = 16807 * (s - k * 127773) - 2836 * k;
	if (s < 0) s += 2147483647;
	seed = uint(s);
	return float(seed % uint(65536)) / 65535.0;
}

uint hash(uint x) {
	x = ((x >> uint(16)) ^ x) * uint(73244475);
	x = ((x >> uint(16)) ^ x) * uint(73244475);
	x = (x >> uint(16)) ^ x;
	return x;
}

void start() {
	uint alt_seed1 = hash(NUMBER + uint(1) + RANDOM_SEED);
	uint alt_seed2 = hash(NUMBER + uint(10) + RANDOM_SEED);
	TRANSFORM = EMISSION_TRANSFORM;
	float percent = float(INDEX) / float(16);
	CUSTOM.x = rand_from_seed(alt_seed1) * TAU;
	CUSTOM.y = 0.0;
	CUSTOM.z = rand_from_seed(alt_seed2);
	float radius = percent * 4.0;
	vec3 position = vec3(cos(CUSTOM.x) * radius, 0.0, sin(CUSTOM.x) * radius);
	TRANSFORM[3].xyz += position;
	VELOCITY = vec3(position.x * 0.1, 1.0, position.z * 0.1) * 0.25 * CUSTOM.z;
}

void process() {
	float percent = float(INDEX) / float(16);
	CUSTOM.y += DELTA / LIFETIME;
	VELOCITY.y *= 0.98;
	
	float scale = texture(scale_curve, vec2(CUSTOM.y, 0.0)).x * 2.0 * (1.0-percent);
	TRANSFORM[0].xyz = normalize(TRANSFORM[0].xyz);
	TRANSFORM[1].xyz = normalize(TRANSFORM[1].xyz);
	TRANSFORM[2].xyz = normalize(TRANSFORM[2].xyz);
	
	TRANSFORM[0].xyz *= scale;
	TRANSFORM[1].xyz *= scale;
	TRANSFORM[2].xyz *= scale;
}
