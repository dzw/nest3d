package nest.control.factories
{
	import nest.view.effects.IEffect;
	import nest.view.lights.*;
	import nest.view.Shader3D;
	
	/**
	 * ShaderFactory
	 */
	public class ShaderFactory {
		
		/**
		 * Create necessary data for shader3d object.
		 */
		public static function create(shader:Shader3D, uv:Boolean = true, specular:Boolean = false, lights:Vector.<ILight> = null, effect:IEffect = null, fog:Boolean = false, kil:Boolean = false):void {
			const normal:Boolean = lights != null;
			
			// vertex shader
			var vertex:String = "m44 op, va0, vc0\n" + 
								"mov v0, va0\n";
			
			if (uv) vertex += "mov v1, va1\n";
			if (normal) vertex += "mov v2, va2\n";
			
			// fragment shader
			var fragment:String = uv ? "tex ft7, v1, fs0 <2d,linear,mipnone>\n" : "mov ft7, fc27\n";
			if (specular) fragment += "tex ft6, v1, fs1 <2d,linear,mipnone>\n";
			if (kil) fragment += "sub ft7.w, ft7.w, fc22.w\nkil ft7.w\n";
			
			// ft5 vertex -> camera
			fragment += "mov ft5, fc21\n" + 
						"m44 ft5, ft5, fc23\n" + 
						"nrm ft5.xyz, ft5\n";
			
			if (lights) {
				// ambient
				fragment += "mul ft0, ft7, fc0\n";
				
				var j:int = 1;
				var light:ILight;
				for each(light in lights) {
					if (light is DirectionalLight) {
						// j    : color
						// j + 1: direction
						fragment += "mov ft2, fc" + (j + 1) + "\n" + 
									"m44 ft2, ft2, fc23\n" + 
									"nrm ft2.xyz, ft2\n" + 
									"dp3 ft3, ft2, v2\n" + 
									"sat ft1, ft3\n" + 
									"mul ft1, ft1, ft7\n" + 
									"mul ft1, ft1, fc" + j + "\n" + 
									"add ft0, ft0, ft1\n";
						if (specular) {
							fragment += "add ft1, ft2, ft5\n" + 
										"dp3 ft4, ft1, ft1\n" + 
										"sqt ft4, ft4\n" + 
										"div ft1, ft1, ft4\n" + 
										"dp3 ft1, ft1, v2\n" + 
										"pow ft1, ft1, fc18.x\n" + 
										"mul ft1, ft1, ft3\n" + 
										"sat ft1, ft1\n" + 
										"mul ft1, ft1, ft6\n" + 
										"mul ft1, ft1, fc" + j + "\n" + 
										"add ft0, ft0, ft1\n";
						}
						j += 2;
					} else if (light is PointLight) {
						// j    : color
						// j + 1: position
						// j + 2: radius
						fragment += "mov ft2, fc" + (j + 1) + "\n" + 
									"m44 ft2, ft2, fc23\n" + 
									"sub ft2, ft2, v0\n" + 
									"dp3 ft3, ft2, ft2\n" + 
									"sqt ft3, ft3\n" + 
									"sub ft3, fc" + (j + 2) + ".w, ft3\n" + 
									"div ft3, ft3, fc" + (j + 2) + ".w\n" + 
									"sat ft3, ft3\n" + 
									"dp3 ft1, ft2, v2\n" + 
									"sat ft1, ft1\n" + 
									"mul ft1, ft1, ft7\n" + 
									"mul ft1, ft1, fc" + j + "\n" + 
									"mul ft1, ft1, ft3\n" + 
									"add ft0, ft0, ft1\n";
						if (specular) {
							fragment += "add ft1, ft2, ft5\n" + 
										"dp3 ft4, ft1, ft1\n" + 
										"sqt ft4, ft4\n" + 
										"div ft1, ft1, ft4\n" + 
										"dp3 ft1, ft1, v2\n" + 
										"pow ft1, ft1, fc18.x\n" + 
										"mul ft1, ft1, ft3\n" + 
										"sat ft1, ft1\n" + 
										"mul ft1, ft1, ft6\n" + 
										"mul ft1, ft1, fc" + j + "\n" + 
										"add ft0, ft0, ft1\n";
						}
						j += 3;
					}
				}
			} else {
				fragment += "mov ft0, ft7\n";
			}
			
			if (effect) fragment += effect.fragment;
			
			if (fog) {
				fragment += "mov ft2,   fc21           \n" + 
							"m44 ft2,   ft2,    fc23   \n" + 
							"sub ft1,   ft2,    v0     \n" + 
							"dp3 ft1.x, ft1,    ft1    \n" + 
							"max ft1.x, ft1.x,  fc19.y \n" + 
							"min ft1.x, ft1.x,  fc19.x \n" + 
							"sub ft1.x, ft1.x,  fc19.y \n" + 
							"mov ft1.y, fc19.y         \n" + 
							"sub ft1.y, fc19.x, ft1.y  \n" + 
							"div ft1.x, ft1.x,  ft1.y  \n" + 
							"sub ft2,   fc20,   ft0    \n" + 
							"mul ft2,   ft1.x,  ft2    \n" + 
							"add ft0,   ft2,    ft0    \n";
			}
			fragment += "mov oc, ft0\n";
			
			shader.setFromString(vertex, fragment, normal);
		}
		
	}

}