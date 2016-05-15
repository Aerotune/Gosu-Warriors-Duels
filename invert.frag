#version 110

uniform sampler2D in_Texture;

varying vec2 var_TexCoord;

void main()
{
  vec4 color = texture2D(in_Texture, var_TexCoord);
	vec4 old_color = color.rgba;
	
	color.b = pow(1.0-old_color.r, 0.7);
	color.g = pow(1.0-old_color.r, 0.7);
	color.r = pow(1.0-old_color.b, 0.7);
	
  gl_FragColor = color.rgba;
}