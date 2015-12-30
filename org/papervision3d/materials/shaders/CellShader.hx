package org.papervision3d.materials.shaders;

import org.papervision3d.core.proto.LightObject3D;
import org.papervision3d.materials.utils.LightMaps;

/**
 *@Author Ralph Hauwert 
 */
class CellShader extends EnvMapShader
{
	
	public function new(light:LightObject3D, color_1:Int=0xFFFFFF, color_2:Int=0x000000, steps:Int=3)
	{
		super(light, LightMaps.getCellMap(color_1, color_2, steps),null, color_2,null,null);
	}
	
}