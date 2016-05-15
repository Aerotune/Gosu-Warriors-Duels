#version 110

uniform sampler2D in_Texture;
uniform float in_R;
uniform float in_G;
uniform float in_B;
varying vec2 var_TexCoord;

void main()
{
  vec4 color = texture2D(in_Texture, var_TexCoord);
	vec4 old_color = color.rgba;
	
	color.r = old_color.r*(1.0-in_R) + 1.0*in_R;
	color.g = old_color.g*(1.0-in_G) + 1.0*in_G;
	color.b = old_color.b*(1.0-in_B) + 1.0*in_B;
	
  gl_FragColor = color.rgba;
}