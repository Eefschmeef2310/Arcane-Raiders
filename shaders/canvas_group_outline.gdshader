shader_type canvas_item;

uniform float outline_width = 2.0;
uniform vec4 outline_color: source_color;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, repeat_disable, filter_nearest;

void fragment() {
	vec4 c = textureLod(SCREEN_TEXTURE, SCREEN_UV, 0.0);

	if (c.a > 0.0001) {
		c.rgb /= c.a;
	}

	COLOR *= c;
	
	//vec4 col = texture(SCREEN_TEXTURE, SCREEN_UV);
	//vec2 ps = TEXTURE_PIXEL_SIZE;
	//float a;
	//float maxa = col.a;
	//float mina = col.a;
//
	//a = texture(SCREEN_TEXTURE, SCREEN_UV + vec2(-outline_width, -outline_width) * ps).a;
	//maxa = max(a, maxa);
	//mina = min(a, mina);
//
	//a = texture(SCREEN_TEXTURE, SCREEN_UV + vec2(outline_width, outline_width) * ps).a;
	//maxa = max(a, maxa);
	//mina = min(a, mina);
//
	//a = texture(SCREEN_TEXTURE, SCREEN_UV + vec2(-outline_width, outline_width) * ps).a;
	//maxa = max(a, maxa);
	//mina = min(a, mina);
//
	//a = texture(SCREEN_TEXTURE, SCREEN_UV + vec2(outline_width, -outline_width) * ps).a;
	//maxa = max(a, maxa);
	//mina = min(a, mina);
//
	//COLOR = mix(col, outline_color, maxa - mina);
	
	
}
