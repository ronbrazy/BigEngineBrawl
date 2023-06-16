package;

import flixel.system.FlxAssets.FlxShader;

class GrayScale extends FlxShader
{
	@:glFragmentSource('
		#pragma header

        void main()
        {	
            vec2 percent = openfl_TextureCoordv;
            percent.y = 1.0 - percent.y;
            
            vec3 pixelColor = texture2D(bitmap, openfl_TextureCoordv).xyz;	
            

            // naive grey scale conversion - average R,G and B
            float pixelGrey = dot(pixelColor, vec3(1.0/3.0));
            pixelColor = vec3(pixelGrey);
            
            gl_FragColor = vec4(pixelColor, texture2D(bitmap, openfl_TextureCoordv).a);			
    }')

	public function new()
	{
		super();
	}
}