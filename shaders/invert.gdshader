shader_type canvas_item;

void fragment() {
	//float average_pixel = dot(COLOR.rgb, vec3(0.2126,0.7152,0.0722));
	//COLOR.rgb = min(vec3(average_pixel), 1.0 - COLOR.rgb);
	//COLOR.rgb = vec3(average_pixel);
	
	COLOR.rgb = 1.0 - COLOR.rgb;
}