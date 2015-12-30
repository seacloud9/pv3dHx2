package org.papervision3d.materials.shaders;

import org.papervision3d.core.proto.LightObject3D;
import org.papervision3d.core.render.data.RenderSessionData;
import org.papervision3d.core.render.shader.ShaderObjectData;
import org.papervision3d.materials.utils.LightMatrix;

/**
 * @Author Ralph Hauwert
 */
class LightShader extends Shader implements IShader, ILightShader
{

	public function new():Void
	{
		super();
	}
	
	private function set_light(light:LightObject3D):Void
	{
		_light=light;
	}
	
	public var light(get_light, set_light):LightObject3D;
 	private function get_light():LightObject3D
	{
		return _light;	
	}
	
	public function updateLightMatrix(sod:ShaderObjectData, renderSessionData:RenderSessionData):Void
	{
		sod.lightMatrices[this]=LightMatrix.getLightMatrix(light, sod.object, renderSessionData,sod.lightMatrices[this]);
	}
	
	private var _light:LightObject3D;
	
}