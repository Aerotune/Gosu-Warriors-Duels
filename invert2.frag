#version 110

uniform sampler2D in_Texture;
uniform float in_Factor;
varying vec2 var_TexCoord;

void main()
{
  vec4 color = texture2D(in_Texture, var_TexCoord);
	vec4 old_color = color.rgba;
	
	color.b = pow((old_color.b * (1.0-in_Factor) + in_Factor * (1.0-old_color.b)), 1.3);
	color.g = pow((old_color.g * (1.0-in_Factor) + in_Factor * (1.0-old_color.g)), 1.3);
	color.r = pow((old_color.r * (1.0-in_Factor) + in_Factor * (1.0-old_color.r)), 1.3);
		
  gl_FragColor = color.rgba;
}