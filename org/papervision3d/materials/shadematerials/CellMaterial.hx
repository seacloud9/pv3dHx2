package org.papervision3d.materials.shadematerials;

import org.papervision3d.core.proto.LightObject3D;
import org.papervision3d.materials.utils.LightMaps;

/**
 * @Author Ralph Hauwert
 */
class CellMaterial extends EnvMapMaterial
{
	public function new(light:LightObject3D, color_1:Int, color_2:Int, steps:Int)
	{
		super(light, LightMaps.getCellMap(color_1, color_2, steps), null, color_2);
	}
	
}