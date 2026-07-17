shader_type canvas_item;

uniform vec4 sky_top : source_color = vec4(0.018, 0.035, 0.090, 1.0);
uniform vec4 sky_horizon : source_color = vec4(0.180, 0.235, 0.300, 1.0);
uniform vec4 dawn_glow : source_color = vec4(0.720, 0.420, 0.190, 1.0);
uniform vec4 water_deep : source_color = vec4(0.012, 0.040, 0.075, 1.0);
uniform vec4 mist_color : source_color = vec4(0.420, 0.500, 0.560, 1.0);

float hash(vec2 point) {
	return fract(sin(dot(point, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 point) {
	vec2 cell = floor(point);
	vec2 local = fract(point);
	local = local * local * (3.0 - 2.0 * local);
	return mix(
		mix(hash(cell), hash(cell + vec2(1.0, 0.0)), local.x),
		mix(hash(cell + vec2(0.0, 1.0)), hash(cell + vec2(1.0, 1.0)), local.x),
		local.y
	);
}

void fragment() {
	vec2 uv = UV;
	float horizon = 0.54;
	float glow = exp(-pow((uv.y - horizon) * 13.0, 2.0)) * exp(-pow((uv.x - 0.68) * 3.1, 2.0));
	vec3 color;

	if (uv.y < horizon) {
		float sky_mix = smoothstep(0.0, horizon, uv.y);
		color = mix(sky_top.rgb, sky_horizon.rgb, sky_mix);
		color += dawn_glow.rgb * glow * 0.24;
	} else {
		float depth = smoothstep(horizon, 1.0, uv.y);
		color = mix(sky_horizon.rgb * 0.42, water_deep.rgb, depth);
		float ripple_a = sin(uv.y * 145.0 + TIME * 0.38 + sin(uv.x * 17.0) * 1.5);
		float ripple_b = sin(uv.y * 83.0 - TIME * 0.22 + uv.x * 31.0);
		float reflection = smoothstep(0.58, 1.0, ripple_a * 0.55 + ripple_b * 0.45);
		float reflection_mask = exp(-pow((uv.x - 0.68) * (7.0 + depth * 8.0), 2.0));
		color += dawn_glow.rgb * reflection * reflection_mask * (1.0 - depth) * 0.22;
	}

	float mist_noise = noise(vec2(uv.x * 3.4 + TIME * 0.012, uv.y * 8.0));
	float mist_band = exp(-pow((uv.y - horizon) * 24.0, 2.0));
	color = mix(color, mist_color.rgb, mist_band * (0.10 + mist_noise * 0.12));

	float vignette = smoothstep(0.95, 0.25, distance(uv, vec2(0.5, 0.48)));
	color *= mix(0.58, 1.0, vignette);
	COLOR = vec4(color, 1.0);
}
