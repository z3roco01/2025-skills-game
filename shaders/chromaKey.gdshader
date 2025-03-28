// MAKE BETTER LOOK AT https://github.com/Ymanawat/Chroma-Key-Shader-Godot-4/blob/master/control.gdshader
shader_type canvas_item;

uniform vec4 chroma : source_color = vec4(1);
uniform float tolerance : hint_range(0, 1) = 0.6;

void fragment() {
	if(distance(COLOR, chroma) < tolerance)
		COLOR = vec4(0);
}