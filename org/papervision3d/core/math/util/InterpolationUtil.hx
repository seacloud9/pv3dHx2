package org.papervision3d.core.math.util;

import org.papervision3d.core.geom.renderables.Vertex3D;
import org.papervision3d.core.math.NumberUV;

class InterpolationUtil
{
	public static function InterpolatePoint(a:Vertex3D, b:Vertex3D, alpha:Float):Vertex3D
	{
		var dst:Vertex3D=new Vertex3D();
		dst.x=a.x + alpha *(b.x - a.x);
		dst.y=a.y + alpha *(b.y - a.y);
		dst.z=a.z + alpha *(b.z - a.z);
		return dst;
	}
	
	public static function InterpolatePointTo(a:Vertex3D, b:Vertex3D, alpha:Float, dst:Vertex3D):Void
	{
		dst.x=a.x + alpha *(b.x - a.x);
		dst.y=a.y + alpha *(b.y - a.y);
		dst.z=a.z + alpha *(b.z - a.z);
	}
	
	public static function InterpolateUV(a:FloatUV, b:FloatUV, alpha:Float):FloatUV
	{
		var dst:FloatUV=new FloatUV();
		dst.u=a.u + alpha *(b.u - a.u);
		dst.v=a.v + alpha *(b.v - a.v);
		return dst;
	}
	
	public static function InterpolateUVTo(a:FloatUV, b:FloatUV, alpha:Float, dst:FloatUV):FloatUV
	{
		dst.u=a.u + alpha *(b.u - a.u);
		dst.v=a.v + alpha *(b.v - a.v);
		return dst;
	}
	
}