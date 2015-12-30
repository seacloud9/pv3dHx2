package org.papervision3d.core.geom.renderables;

import flash.display.Sprite;

import org.papervision3d.core.math.Number3D;
import org.papervision3d.objects.DisplayObject3D;

class Triangle3DInstance
{
	public var instance:DisplayObject3D;
	
	/**
	* container is initialized via DisplayObject3D's render method IF DisplayObject3D.faceLevelMode is set to true
	*/
	public var container:Sprite;
	public var visible:Bool=false;
	public var screenZ:Float;
	public var faceNormal:Float3D;
	
	public function new(face:Triangle3D, instance:DisplayObject3D)
	{
		this.instance=instance;
		faceNormal=new Float3D();
	}
}