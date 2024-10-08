shader_type canvas_item;

uniform float final_saturation: hint_range(0.0, 1.0, 0.01) = 0.5;

void fragment() {
	COLOR.rgb = mix(vec3(dot(texture(TEXTURE, UV).rgb, vec3(0.2126,0.7152,0.0722)), texture(TEXTURE, UV).rgb, final_saturation);
}