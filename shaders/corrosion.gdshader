shader_type canvas_item;

uniform float fade_scale : hint_range(0.0, 1.0) = 0.5;
uniform sampler2D noise_texture : repeat_enable;

uniform float alpha : hint_range(0.0, 1.0) = 1;

void fragment() {
	//Get height threshold of noise
	float height_cutoff = round(mix(fade_scale, texture(noise_texture, UV).r, 0.5));
	
	float mask = texture(TEXTURE, UV).a;

	//Set final albedo (if height in noise is higher than cutoff, use end colour, otherwise do base color)
	COLOR.a = 1.0 - step(mask, height_cutoff);
	COLOR.a *= alpha;
}