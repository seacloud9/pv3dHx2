package org.papervision3d.core.math.util;

import org.papervision3d.core.geom.renderables.Triangle3D;
import org.papervision3d.core.geom.renderables.Vertex3D;
import org.papervision3d.core.math.NumberUV;
import org.papervision3d.core.math.Plane3D;

class TriangleUtil
{
	/**
	 * Clips a triangle to a plane.
	 * 
	 * @param	tri		Triangle to be clipped.
	 * @param	plane	Plane to clip to.
	 * @param	e	Epsilon
	 */ 
	public static function clipTriangleWithPlane(tri:Triangle3D, plane:Plane3D, e:Float=0.01):Array
	{
		var points:Array<Dynamic>=[tri.v0, tri.v1, tri.v2];
		var uvs:Array<Dynamic>=[tri.uv0, tri.uv1, tri.uv2];
		var out:Array<Dynamic>=new Array();
		var outuv:Array<Dynamic>=new Array();
		var isect:Intersection;
		var s:Vertex3D=points[points.length-1];
		var p:Vertex3D;
		var suv:FloatUV=uvs[points.length-1];
		var puv:FloatUV;
		var cp:Int;
		var cs:Int;
		for(i in 0...points.length)
		{
			p=points[i];	
			puv=uvs[i];
				
			cp=ClassificationUtil.classifyPoint(p, plane, e);
			cs=ClassificationUtil.classifyPoint(s, plane, e);
			
			if(cp==ClassificationUtil.FRONT)
			{
				if(cs==ClassificationUtil.FRONT)
				{
					// output p
					out.push(p);
					outuv.push(puv);
				}	
				else
				{
					// compute Intersection	s, p, plane
					isect=Intersection.linePlane(s, p, plane, e);
					if(isect.status !=Intersection.INTERSECTION)
					{
						plane.d +=1;
						return clipTriangleWithPlane(tri, plane, e);
					}
					
					//tri.instance.geometry.vertices.push(isect.vert);
					
					out.push(isect.vert);
					outuv.push(InterpolationUtil.interpolateUV(suv, puv, isect.alpha));
				
					// output p
					out.push(p);
					outuv.push(puv);
				}
			}
			else if(cs==ClassificationUtil.FRONT)
			{
				isect=Intersection.linePlane(p, s, plane, e);
				if(isect.status !=Intersection.INTERSECTION)
				{
					plane.d +=1;
					return clipTriangleWithPlane(tri, plane, e);
				}
				
				//tri.instance.geometry.vertices.push(isect.vert);
						
				out.push(isect.vert);
				outuv.push(InterpolationUtil.interpolateUV(puv, suv, isect.alpha));
			}

			s=p;
			suv=puv;
		}
			
		if(out.length==3)
		{
			return [new Triangle3D(tri.instance, [out[0], out[1], out[2]], tri.material, [outuv[0], outuv[1], outuv[2]])];
		}
		else if(out.length==4)
		{
			return [new Triangle3D(tri.instance, [out[0], out[1], out[2]], tri.material, [outuv[0], outuv[1], outuv[2]]),
					new Triangle3D(tri.instance, [out[0], out[2], out[3]], tri.material, [outuv[0], outuv[2], outuv[3]])];
		}
		
		return null;
	}
	
	public static function clipTriangleWithPlaneTris(tri:Triangle3D, plane:Plane3D, e:Float=0.01, t1:Triangle3D=null, t2:Triangle3D=null, depth:Float=0):Array
	{

		if(depth>420)
			return [tri];

		var points:Array<Dynamic>=tri.vertices;//[tri.v0, tri.v1, tri.v2];
		var uvs:Array<Dynamic>=tri.uv;//[tri.uv0, tri.uv1, tri.uv2];
		var out:Array<Dynamic>=new Array();
		var outuv:Array<Dynamic>=new Array();
		var isect:Intersection;
		var s:Vertex3D=points[points.length-1];
		var p:Vertex3D;
		var suv:FloatUV=uvs[points.length-1];
		var puv:FloatUV;
		var cp:Int;
		var cs:Int;
		for(i in 0...points.length)
		{
			p=points[i];	
			puv=uvs[i];
				
			cp=ClassificationUtil.classifyPoint(p, plane, e);
			cs=ClassificationUtil.classifyPoint(s, plane, e);
			
			if(cp==ClassificationUtil.FRONT)
			{
				if(cs==ClassificationUtil.FRONT)
				{
					// output p
					out.push(p);
					outuv.push(puv);
				}	
				else
				{
					// compute Intersection	s, p, plane
					isect=Intersection.linePlane(s, p, plane, e);
					if(isect.status !=Intersection.INTERSECTION)
					{
						plane.d -=0.05;
						
						return clipTriangleWithPlaneTris(tri, plane, e, t1, t2, depth+1);
					}
					
					//tri.instance.geometry.vertices.push(isect.vert);
					
					out.push(isect.vert);
					outuv.push(InterpolationUtil.interpolateUV(suv, puv, isect.alpha));
				
					// output p
					out.push(p);
					outuv.push(puv);
				}
			}
			else if(cs==ClassificationUtil.FRONT)
			{
				isect=Intersection.linePlane(p, s, plane, e);
				if(isect.status !=Intersection.INTERSECTION)
				{
					plane.d -=0.05;
					
					return clipTriangleWithPlaneTris(tri, plane, e, t1, t2, depth+1);
				}
				
				//tri.instance.geometry.vertices.push(isect.vert);
						
				out.push(isect.vert);
				outuv.push(InterpolationUtil.interpolateUV(puv, suv, isect.alpha));
			}

			s=p;
			suv=puv;
		}
			
		if(out.length==3)
		{
			t1.reset(tri.instance, [out[0], out[1], out[2]], tri.material, [outuv[0], outuv[1], outuv[2]]);
			return [t1];
			
		}
		else if(out.length==4)
		{
			
			 t1.reset(tri.instance, [out[0], out[1], out[2]], tri.material, [outuv[0], outuv[1], outuv[2]]);
			 t2.reset(tri.instance, [out[0], out[2], out[3]], tri.material, [outuv[0], outuv[2], outuv[3]]);
			
			return [t1,t2];
			
		}
		
		return null;
	}
	
	public static function clipSplitTriangleWithPlane(triangle:Triangle3D, plane:Plane3D, e:Float=0.01):Array
	{
		var outArr:Array<Dynamic>=new Array();
		var a1:Array<Dynamic>=clipTriangleWithPlane(triangle, plane, e);
		var a2:Array<Dynamic>=clipTriangleWithPlane(triangle, plane.getTempFlip(), e);
		if(a1==null && a2==null){
			return null;
		}else{
			if(a1 !=null && a1.length){
				outArr=outArr.concat(a1);
			}
			if(a2 !=null && a2.length){
				outArr=outArr.concat(a2);
			}
		}
		return outArr;
	}
					
	public static function splitTriangleWithPlane(triangle:Triangle3D, plane:Plane3D, e:Float=0.01):Array
	{
		var side:Int=ClassificationUtil.classifyTriangle(triangle, plane);
		if(side !=ClassificationUtil.STRADDLE){
			return null;
		}
		var pA:Vertex3D;
		var pB:Vertex3D;
		var uvA:FloatUV;
		var uvB:FloatUV;
		var sideA:Float;
		var sideB:Float;
		var isect:Intersection;
		var newUV:FloatUV;
		
		var points:Array<Dynamic>=[triangle.v0, triangle.v1, triangle.v2];
		var uvs:Array<Dynamic>=[triangle.uv0, triangle.uv1, triangle.uv2];
		var triA:Array<Dynamic>=new Array();
		var triB:Array<Dynamic>=new Array();
		var uvsA:Array<Dynamic>=new Array();
		var uvsB:Array<Dynamic>=new Array();
		
		for(i in 0...points.length){
			var j:Int=(i+1)% points.length;
			
			pA=points[i];
			pB=points[j];
			
			uvA=uvs[i];
			uvB=uvs[j];
			
			sideA=plane.distance(pA);
			sideB=plane.distance(pB);
			if(sideB>e){
				if(sideA<-e){
					isect=Intersection.linePlane(pA, pB, plane,e);
					if(isect.status !=Intersection.INTERSECTION){
						plane.d +=1;
						return splitTriangleWithPlane(triangle, plane, e);
					}
					triangle.instance.geometry.vertices.push(isect.vert);
					triA.push(isect.vert);
					triB.push(isect.vert);
					newUV=InterpolationUtil.interpolateUV(uvA, uvB, isect.alpha);
					uvsA.push(newUV);
					uvsB.push(newUV);
				}
				triA.push(pB);
				uvsA.push(uvB);
			}
			else if(sideB<-e)
			{
				if(sideA>e){
					isect=Intersection.linePlane(pA, pB, plane,e);
					if(isect.status !=Intersection.INTERSECTION){
						plane.d +=1;
						return splitTriangleWithPlane(triangle, plane, e);
					}
					triangle.instance.geometry.vertices.push(isect.vert);
					triA.push(isect.vert);
					triB.push(isect.vert);
					newUV=InterpolationUtil.interpolateUV(uvA, uvB, isect.alpha);
					uvsA.push(newUV);
					uvsB.push(newUV);
				}
				triB.push(pB);
				uvsB.push(uvB);
			}else{
				triA.push(pB);
				triB.push(pB);
				uvsA.push(uvB);
				uvsB.push(uvB);
			}
		}
		var tris:Array<Dynamic>=new Array();
		tris.push(new Triangle3D(triangle.instance, [triA[0], triA[1], triA[2]], triangle.material, [uvsA[0], uvsA[1], uvsA[2]]));
		tris.push(new Triangle3D(triangle.instance, [triB[0], triB[1], triB[2]], triangle.material, [uvsB[0], uvsB[1], uvsB[2]]));
		
		if(triA.length>3)
			tris.push(new Triangle3D(triangle.instance, [triA[0], triA[2], triA[3]], triangle.material, [uvsA[0], uvsA[2], uvsA[3]]));
		else if(triB.length>3)
			tris.push(new Triangle3D(triangle.instance, [triB[0], triB[2], triB[3]], triangle.material, [uvsB[0], uvsB[2], uvsB[3]]));
		return tris;
	}
}