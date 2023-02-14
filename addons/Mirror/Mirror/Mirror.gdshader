shader_type spatial;
render_mode cull_disabled, unshaded;

uniform vec4 tint : source_color = vec4(vec3(0.98),1.0);
uniform sampler2D mirror_tex;
uniform sampler2D distort_tex : source_color;
uniform float distort_strength : hint_range(0, 30);

void vertex() {
	UV.x = 1.0 - UV.x;
}

//vec3 lin_to_srgb(vec3 col) {
//	return mix(
//		pow((col + vec3(0.055)) * (1.0 / (1.0 + 0.055)),vec3(2.4)),
//		col * (1.0 / 12.92),
//		lessThan(col,vec3(0.04045))
//		);
//}

void fragment() {
	vec2 m_UV = UV;
	
	// Backface texcoord flip correction
	if (!FRONT_FACING) {
		m_UV.x = 1.0 - m_UV.x;
	}
	
	float distort_ofs = texture(distort_tex, m_UV).r;
	
	// Map offset to [-1, 1] region
	distort_ofs = (distort_ofs * 2.0) - 1.0;
	
	
	vec2 base_uv = m_UV + distort_ofs * distort_strength / VIEWPORT_SIZE;
	vec4 mirror_sample = texture(mirror_tex,base_uv);
	
	ALBEDO = tint.rgb * mirror_sample.rgb;
}
