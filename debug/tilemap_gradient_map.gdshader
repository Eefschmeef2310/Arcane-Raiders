shader_type canvas_item;

uniform sampler2D gradient;

uniform float final_saturation: hint_range(0.0, 1.0, 0.01);

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	
	//Get desaturated value
	float luminance = dot(tex_color.rgb, vec3(0.2126,0.7152,0.0722));
	
	//Use lumincance to get final desaturated pixel
	vec3 recoloured_pixel = texture(gradient, vec2(luminance,0)).rgb;
	
	COLOR.rgb = mix(vec3(dot(recoloured_pixel, vec3(0.299, 0.587, 0.114))), recoloured_pixel, final_saturation);
	
	//Makes sure transparency is maintained
	COLOR.a = tex_color.a;
}
