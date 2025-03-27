shader_type canvas_item;

uniform vec4 colour : source_color = vec4(1);

void vertex() {
	COLOR = colour;
}

void fragment() {
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
