// gpt'd :s
// TODO(Yohanan): understand this !!!!!!!!!!

shader_type spatial;

render_mode blend_mix, depth_draw_opaque, cull_back;

// Distance at which the object is still fully visible.
uniform float visible_distance : hint_range(0.0, 100.0) = 5.0;

// Distance at which the object is completely invisible.
uniform float fade_distance : hint_range(0.0, 100.0) = 1.0;

uniform vec4 object_color : source_color = vec4(1.0);

varying vec3 world_position;

// 4x4 Bayer matrix.
const float BAYER_4X4[16] = float[](
	0.0,    0.5,    0.125,  0.625,
	0.75,   0.25,   0.875,  0.375,
	0.1875, 0.6875, 0.0625, 0.5625,
	0.9375, 0.4375, 1.0,    0.8125
);

void vertex() {
	/// what the fuck does this mean
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec3 camera_position = INV_VIEW_MATRIX[3].xyz;
	float camera_distance = distance(world_position, camera_position);

    // Use screen pixels for dither pattern
	ivec2 pixel = ivec2(FRAGCOORD.xy);
	int index = (pixel.x % 4) + (pixel.y % 4) * 4;
	float threshold = BAYER_4X4[index];

	ALPHA_SCISSOR_THRESHOLD = threshold;
	ALPHA = smoothstep(fade_distance, visible_distance, camera_distance);
	ALBEDO = object_color.rgb;
	ROUGHNESS = 1.0;
} 