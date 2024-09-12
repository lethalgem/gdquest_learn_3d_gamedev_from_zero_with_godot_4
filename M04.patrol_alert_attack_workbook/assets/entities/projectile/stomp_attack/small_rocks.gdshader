shader_type particles;
render_mode collision_use_scale;

uniform float base_scale = 0.5;
uniform float collision_friction = 0.5;
uniform float collision_bounce = 0.5;
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

mat3 rotateX(float theta) {
	float c = cos(theta);
	float s = sin(theta);
	return mat3(
		vec3(1, 0, 0),
		vec3(0, c, -s),
		vec3(0, s, c)
	);
}

mat3 rotateY(float theta) {
	float c = cos(theta);
	float s = sin(theta);
	return mat3(
		vec3(c, 0, s),
		vec3(0, 1, 0),
		vec3(-s, 0, c)
	);
}

mat3 rotateZ(float theta) {
    float c = cos(theta);
    float s = sin(theta);
    return mat3(
        vec3(c, -s, 0),
        vec3(s, c, 0),
        vec3(0, 0, 1)
    );
}

void start() {
	uint alt_seed1 = hash(NUMBER + uint(1) + RANDOM_SEED);
	TRANSFORM = EMISSION_TRANSFORM;
	float percent = float(INDEX) / float(8);
	CUSTOM.x = rand_from_seed(alt_seed1);
	float angle = CUSTOM.x * TAU;
	CUSTOM.y = 0.0;
	float radius = percent * 2.5;
	vec3 position = vec3(cos(angle) * radius, 0.0, sin(angle) * radius);
	TRANSFORM[3].xyz += position;
	VELOCITY = vec3(position.x, 2.0, position.z);
	TRANSFORM *= mat4(rotateY(angle) * rotateX(angle));
}

void process() {
	float percent = float(INDEX) / float(16);
	CUSTOM.y += DELTA / LIFETIME;
	VELOCITY.y -= 0.25;
	if (COLLIDED) {
		if (length(VELOCITY) > 3.0) {
			TRANSFORM[3].xyz += COLLISION_NORMAL * COLLISION_DEPTH;
			VELOCITY -= COLLISION_NORMAL * dot(COLLISION_NORMAL, VELOCITY) * (1.0 + collision_bounce);
			VELOCITY = mix(VELOCITY,vec3(0.0),clamp(collision_friction, 0.0, 1.0));
		} else {
			VELOCITY = vec3(0.0);
		}
	}
	float scale = texture(scale_curve, vec2(CUSTOM.y, 0.0)).x * base_scale * (1.0 - percent);
	TRANSFORM *= mat4(rotateZ(abs(length(VELOCITY)) * 0.1));

	TRANSFORM[0].xyz = normalize(TRANSFORM[0].xyz);
	TRANSFORM[1].xyz = normalize(TRANSFORM[1].xyz);
	TRANSFORM[2].xyz = normalize(TRANSFORM[2].xyz);
	
	TRANSFORM[0].xyz *= scale;
	TRANSFORM[1].xyz *= scale;
	TRANSFORM[2].xyz *= scale;
}
