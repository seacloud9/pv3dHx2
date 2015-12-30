package org.papervision3d.core.math;

import org.papervision3d.core.math.Number3D;

class Sphere3D
{
	public var x:Float;
	public var y:Float;
	public var z:Float;
	public var radius:Float;
	
	public function new(r:Float=100, x:Float=0, y:Float=0, z:Float=0)
	{
		this.radius=r;
		this.x=x;
		this.y=y;
		this.z=z;
	}
	
	public function get o():Float3D{
		return new Float3D(x, y, z);
	}
	
	public var r2(get_r2, null):Float;
 	private function get_r2():Float{
		return radius*radius;
	}
	

	public function IntersectRay(ray:Ray3D):Float{
		var dst:Float3D=Number3D.sub(ray.o, o);
		var b:Float=Number3D.dot(dst, ray.d);
		var c:Float=Number3D.dot(dst, dst)-r2;
		var d:Float=b*b-c;
		if(d>0)
			return -b-Math.sqrt(d);
		else 
			return -999999;
	}
}