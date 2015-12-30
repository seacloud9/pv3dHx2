package org.papervision3d.core.material;

import flash.utils.Dictionary;

import org.papervision3d.core.material.TriangleMaterial;
import org.papervision3d.core.math.Matrix3D;
import org.papervision3d.core.proto.LightObject3D;
import org.papervision3d.core.render.data.RenderSessionData;
import org.papervision3d.core.render.draw.ITriangleDrawer;
import org.papervision3d.core.render.material.IUpdateBeforeMaterial;
import org.papervision3d.materials.utils.LightMatrix;
import org.papervision3d.objects.DisplayObject3D;

class AbstractLightShadeMaterial extends TriangleMaterial implements ITriangleDrawer, IUpdateBeforeMaterial
{

	public var lightMatrices:Dictionary;
	private var _light:LightObject3D;
	protected static var lightMatrix:Matrix3D;
	
	public function new()
	{
		super();
		init();
	}
	
	private function init():Void
	{
		lightMatrices=new Dictionary();
	}
	
	public function updateBeforeRender(renderSessionData:RenderSessionData):Void
	{	
		for(object in objects){
			var do3d:DisplayObject3D=cast(object, DisplayObject3D);
			lightMatrices[object]=LightMatrix.getLightMatrix(light, do3d, renderSessionData, lightMatrices[object]);
		}
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
	
}