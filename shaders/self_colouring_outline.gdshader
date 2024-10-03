shader_type canvas_item;

uniform float outline_width = 2.0;
uniform float darken_amount : hint_range(0.0, 1.0) = 0.5;

void fragment() {
	vec4 col = texture(TEXTURE, UV);
	vec2 ps = TEXTURE_PIXEL_SIZE;
	float a;
	float maxa = col.a;
	float mina = col.a;

	a = texture(TEXTURE, UV + vec2(-outline_width, -outline_width) * ps).a;
	maxa = max(a, maxa);
	mina = min(a, mina);

	a = texture(TEXTURE, UV + vec2(outline_width, outline_width) * ps).a;
	maxa = max(a, maxa);
	mina = min(a, mina);

	a = texture(TEXTURE, UV + vec2(-outline_width, outline_width) * ps).a;
	maxa = max(a, maxa);
	mina = min(a, mina);

	a = texture(TEXTURE, UV + vec2(outline_width, -outline_width) * ps).a;
	maxa = max(a, maxa);
	mina = min(a, mina);

	COLOR.rgb = mix(col.rgb, texture(TEXTURE, UV).rgb - darken_amount, maxa - mina);
}
