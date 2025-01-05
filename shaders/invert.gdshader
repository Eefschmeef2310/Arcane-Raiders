shader_type canvas_item;

void fragment() {
	COLOR.rgb = 1.0 - COLOR.rgb;
}