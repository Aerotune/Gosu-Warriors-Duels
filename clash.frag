#version 110

uniform sampler2D in_Texture;

varying vec2 var_TexCoord;

void main()
{
  vec4 color = texture2D(in_Texture, var_TexCoord);
	vec4 old_color = color.rgba;
	
	color.r = old_color.r+old_color.b;
	color.g = old_color.g;
	color.b = old_color.r+old_color.b;
	
  gl_FragColor = color.rgba;
}