package org.papervision3d.core.proto;

import org.papervision3d.core.math.Matrix3D;
import org.papervision3d.materials.WireframeMaterial;
import org.papervision3d.objects.DisplayObject3D;
import org.papervision3d.objects.primitives.Sphere;

class LightObject3D extends DisplayObject3D
{
	public var lightMatrix:Matrix3D;
	
	/** 
	 * A boolean value indicating whether to flip the light direction. Hack needed by DAE. 
	 * NOTE:
	 */
	public var flipped:Bool;
	
	private var _showLight:Bool;
	
	private var displaySphere:Sphere;
	
	public function new(showLight:Bool=false, flipped:Bool=false)
	{
		super();
		this.lightMatrix=Matrix3D.IDENTITY;
		this.showLight=showLight;
		this.flipped=flipped;
	}
	
	private function set_showLight(show:Bool):Void
	{
		if(_showLight){
			removeChild(displaySphere);
		}
		if(show){
			displaySphere=new Sphere(new WireframeMaterial(0xffff00), 10, 3, 2);
			addChild(displaySphere);
		}
		_showLight=show;
	}
	
	public var showLight(get_showLight, set_showLight):Bool;
 	private function get_showLight():Bool
	{
		return _showLight;
	}
}