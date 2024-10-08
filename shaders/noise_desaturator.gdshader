shader_type canvas_item;

uniform sampler2D gradient;

uniform float final_saturation: hint_range(0.0, 1.0, 0.01) = 0.5;

uniform sampler2D noise : repeat_enable;

uniform float noise_min : hint_range(0.0, 1.0) = 0;
uniform float noise_max : hint_range(0.0, 1.0) = 1;

void fragment() {
	if (texture(noise, UV).a == 0.){
		discard;
	}
		
	vec3 col = texture(noise, UV).rgb;
	col = clamp(col, noise_min, noise_max);
	
	//Get desaturated value
	float luminance = dot(col, vec3(0.2126,0.7152,0.0722));
	
	//Use lumincance to get final desaturated pixel
	vec3 recoloured_pixel = texture(gradient, vec2(luminance,0)).rgb;
	
	COLOR.rgb = mix(vec3( dot(recoloured_pixel, vec3(0.2126,0.7152,0.0722) ) ), recoloured_pixel, final_saturation);
}