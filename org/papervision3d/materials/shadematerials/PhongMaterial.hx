package org.papervision3d.materials.shadematerials;

import org.papervision3d.core.proto.LightObject3D;
import org.papervision3d.materials.utils.LightMaps;

/**
 * @Author Ralph Hauwert
 */
class PhongMaterial extends EnvMapMaterial
{
	public function new(light:LightObject3D, lightColor:Int, ambientColor:Int, specularLevel:Int)
	{
		super(light, LightMaps.getPhongMap(lightColor, ambientColor, specularLevel), null, ambientColor);
	}
	
}