package org.papervision3d.core.math.util;

import org.papervision3d.core.geom.renderables.Triangle3D;
import org.papervision3d.core.geom.renderables.Vertex3D;
import org.papervision3d.core.math.Plane3D;

class ClassificationUtil
{
	public static inline var FRONT:Int=0;
	public static inline var BACK:Int=1;
	public static inline var COINCIDING:Int=2;
	public static inline var STRADDLE:Int=3;
	
	public function new()
	{
		
	}
	
	public static function classifyPoint(point:Vertex3D, plane:Plane3D, e:Float=0.01):Int
	{
		var distance:Float=plane.vertDistance(point);
		if(distance<-e){
			return BACK;
		}else if(distance>e){
			return FRONT;
		}else{ 
			return COINCIDING;
		}
	}
	
	protected static var point:Vertex3D;
	public static function classifyPoints(points:Array, plane:Plane3D, e:Float=0.01):Int
	{
		var numpos:Int=0;
		var numneg:Int=0;
		for(point in points)
		{
			var side:Int=classifyPoint(point, plane, e);
			if(side==FRONT){
				numpos++;
			}else if(side==BACK){
				numneg++;
			}
		}
		if(numpos>0 && numneg==0){
			return FRONT;
		}else if(numpos==0 && numneg>0){
			return BACK;
		}else if(numpos>0 && numneg>0){
			return STRADDLE;
		}else{
			return COINCIDING;
		}
	}
	
	public static function classifyTriangle(triangle:Triangle3D, plane:Plane3D, e:Float=0.01):Int
	{			
		if(!triangle){
			return null;
		}
		return classifyPoints(triangle.vertices, plane, e);//[triangle.v0, triangle.v1, triangle.v2], plane, e);
	}
	
}