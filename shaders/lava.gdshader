shader_type canvas_item;

uniform sampler2D noise;

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	vec4 noise_color = texture(noise, UV);
	
	COLOR.rgb = mix(vec3(dot(tex_color.rgb, vec3(0.2126,0.7152,0.0722))), tex_color.rgb, clamp(texture(noise, UV).r + sin(TIME), 1, 1.5));
	//COLOR.rgb = tex_color.rgb;
	
	//Makes sure transparency is maintained
	COLOR.a = tex_color.a;
}