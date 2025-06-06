shader_type canvas_item;

const vec4 bg_color = vec4(0.278, 0.176, 0.235, 1.0);
const float tolerance = 0.01;

void fragment() {
	if (distance(COLOR, bg_color) > tolerance)
		COLOR *= vec4(0.7, 0.7, 0.7, 1.0);
}