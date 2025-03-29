shader_type canvas_item;

uniform vec3 chroma : source_color = vec3(1);
uniform float tolerance : hint_range(0, 1) = 0.6;
uniform float fadeAmount : hint_range(0, 1) = 0.5;
uniform bool enabled = true;

float compare_rbg_values(vec3 orig, vec3 transparent) {
	float r = abs(orig.r - transparent.r);
	float g = abs(orig.g - transparent.g);
	float b = abs(orig.b - transparent.b);
	return smoothstep(tolerance * fadeAmount, tolerance, (r+g+b)/3.0);
}

void fragment() {
	if(enabled) {
		float comparison = compare_rbg_values(COLOR.rgb, chroma.rgb);
		COLOR = vec4(COLOR.rgb,comparison);
	}
}