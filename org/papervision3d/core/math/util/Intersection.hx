package org.papervision3d.core.math.util;

import org.papervision3d.core.geom.renderables.Vertex3D;
import org.papervision3d.core.math.Number3D;
import org.papervision3d.core.math.Plane3D;

class Intersection
{
	public static inline var NONE:Int=0;
	public static inline var INTERSECTION:Int=1;
	public static inline var PARALLEL:Int=2;
	
	public var point:Float3D;
	public var vert:Vertex3D;
	public var alpha:Float=0;
	public var status:Int;
	
	public function new(point:Float3D=null, vert:Vertex3D=null)
	{
		if(point !=null){
			this.point=point;
		}else{
			this.point=new Float3D();
		}
		if(vert !=null){
			this.vert=vert;
		}else{
			this.vert=new Vertex3D();
		}
	}

	public static function linePlane(pA:Vertex3D, pB:Vertex3D, plane:Plane3D, e:Float=0.01, dst:Intersection=null):Intersection
	{
		if(dst==null){
			dst=new Intersection();
		}
		var a:Float=plane.normal.x;
		var b:Float=plane.normal.y;
		var c:Float=plane.normal.z;
		var d:Float=plane.d;
		var x1:Float=pA.x;
		var y1:Float=pA.y;
		var z1:Float=pA.z;
		var x2:Float=pB.x;
		var y2:Float=pB.y;
		var z2:Float=pB.z;
		
		var r0:Float=(a * x1)+(b * y1)+(c * z1)+ d;
		var r1:Float=a*(x1-x2)+ b*(y1-y2)+ c*(z1-z2);
		var u:Float=r0 / r1;
		
		if(Math.abs(u)<e){
			dst.status=Intersection.PARALLEL;
		} else if((u>0 && u<1)){
			dst.status=Intersection.INTERSECTION;
			var pt:Float3D=dst.point;
			pt.x=x2 - x1;
			pt.y=y2 - y1;
			pt.z=z2 - z1;
			pt.x *=u;
			pt.y *=u;
			pt.z *=u;
			pt.x +=x1;
			pt.y +=y1;
			pt.z +=z1;
			
			dst.alpha=u;
			
			dst.vert.x=pt.x;
			dst.vert.y=pt.y;
			dst.vert.z=pt.z;
		}else{
			dst.status=Intersection.NONE;
		}
		
		return dst;
	}

}