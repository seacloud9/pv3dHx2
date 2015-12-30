package org.papervision3d.core.math;

import org.papervision3d.core.math.Number3D;

class Ray3D
{
	public var x:Float;
	public var y:Float;
	public var z:Float;
	public var dx:Float;
	public var dy:Float;
	public var dz:Float;
	
	public function new(x:Float=0, y:Float=0, z:Float=0, dx:Float=0, dy:Float=0, dz:Float=0)
	{
		this.x=x;
		this.y=y;
		this.z=z;
		this.dx=dx;
		this.dy=dy;
		this.dz=dz;	
	}
	
	public function get o():Float3D{
		return new Float3D(x, y, z);
	}
	
	public function get d():Float3D{
		return new Float3D(dx, dy, dz);
	}
	
	

}