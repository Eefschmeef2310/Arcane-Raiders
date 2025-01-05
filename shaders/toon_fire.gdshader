shader_type canvas_item;

uniform sampler2D noise_tex : repeat_enable;
uniform sampler2D gradient_tex;
uniform sampler2D gradient;

uniform float spread : hint_range(0.0, 1.0) = 0.5;
uniform float speed = 1;
uniform float final_saturation: hint_range(0.0, 1.0, 0.01) = 0.5;
uniform float alpha : hint_range(0.0, 1.0) = 0.5; // Add uniform for alpha control

uniform float outer_thickness : hint_range(0.0, 1.0, 0.01) = 0.2;
uniform float middle_thickness : hint_range(0.0, 1.0, 0.01) = 0.4;

void fragment() {
    float noise_value = texture(noise_tex, UV + vec2(0.0, TIME * speed)).r;
    // Sample the gradient map texture at UV coordinates
    float gradient_value = texture(gradient_tex, UV).x;

    gradient_value -= smoothstep(spread, spread + 0.5, length(UV + vec2(-0.5, -0.5)) / spread);

    float step1 = step(noise_value, gradient_value);
    float step2 = step(noise_value, gradient_value - outer_thickness);
    float step3 = step(noise_value, gradient_value - middle_thickness);

    // Sample the gradient map texture at different points
    vec4 gradient_color1 = texture(gradient, vec2(1.));
    vec4 gradient_color2 = texture(gradient, vec2(0.55));
    vec4 gradient_color3 = texture(gradient, vec2(0.5));

    vec4 bd_color = mix(gradient_color1, gradient_color3, step1 - step2);
	
    vec4 color = vec4(bd_color.rgb, step1);
    color = mix(color, gradient_color2, step2 - step3);

    // Desaturate the final color
    float luminance = dot(color.rgb, vec3(0.2126,0.7152,0.0722));
    vec3 desaturated_color = color.rgb;
    color.rgb = mix(vec3(dot(desaturated_color, vec3(0.2126,0.7152,0.0722))), desaturated_color, final_saturation);

    // Apply alpha control
    color.a *= alpha;

    COLOR = color;
}
