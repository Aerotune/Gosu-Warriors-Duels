#version 110

uniform sampler2D in_Texture;

varying vec2 var_TexCoord;

void main()
{
  vec4 color = texture2D(in_Texture, var_TexCoord);
	vec4 old_color = color.rgba;
	
	color.r = 1.0;
	color.g = 1.0;
	color.b = 1.0;
	
  gl_FragColor = color.rgba;
}