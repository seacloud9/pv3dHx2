package org.papervision3d.core.math;

import org.papervision3d.core.geom.renderables.Vertex3D;

class BoundingSphere
{
	//The non squared maximum vertex distance.
	public var maxDistance:Float;
	
	//The squared maximum vertex distance.
	public var radius:Float;
	
	/**
	 * @Author Ralph Hauwert
	 */
	public function new(maxDistance:Float)
	{
		this.maxDistance=maxDistance;
		this.radius=Math.sqrt(maxDistance);
	}
	
	public static function getFromVertices(vertices:Array):BoundingSphere
	{
		var max:Float=0;
		var d:Float;
		var v:Vertex3D;
		for(v in vertices)
		{
			d=v.x*v.x + v.y*v.y + v.z*v.z;
			max=(d>max)? d:max;
		}
		return new BoundingSphere(max);
	}

}