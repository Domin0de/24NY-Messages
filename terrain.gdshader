shader_type spatial;

uniform sampler2D grass_texture;
uniform sampler2D hill_texture;

uniform float min_hill_slope:hint_range(0.f, 1.f) = 0.5;
uniform float max_grass_slope:hint_range(0.f, 1.f) = 0.8;

varying float normal_y;

void vertex() {
	normal_y = NORMAL.y;
}

void fragment() {
	vec3 grass_albedo = texture(grass_texture, UV*4.f).xyz;
	vec3 hill_albedo = texture(hill_texture, UV*4.f).xyz;

	float hill_grass_weight = normal_y;

	hill_grass_weight = max(min_hill_slope, hill_grass_weight);
	hill_grass_weight = min(max_grass_slope, hill_grass_weight);
	hill_grass_weight -= min_hill_slope;
	hill_grass_weight /= max_grass_slope - min_hill_slope;

	ALBEDO = mix(hill_albedo, grass_albedo, hill_grass_weight);
}
