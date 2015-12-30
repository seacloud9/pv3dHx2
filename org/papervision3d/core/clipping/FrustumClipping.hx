package org.papervision3d.core.clipping;

import org.papervision3d.core.dyn.DynamicTriangles;
import org.papervision3d.core.geom.renderables.Triangle3D;
import org.papervision3d.core.geom.renderables.Vertex3D;
import org.papervision3d.core.log.PaperLogger;
import org.papervision3d.core.math.Matrix3D;
import org.papervision3d.core.math.Number3D;
import org.papervision3d.core.math.NumberUV;
import org.papervision3d.core.math.Plane3D;
import org.papervision3d.core.math.util.ClassificationUtil;
import org.papervision3d.core.proto.CameraObject3D;
import org.papervision3d.core.proto.MaterialObject3D;
import org.papervision3d.core.render.data.RenderSessionData;
import org.papervision3d.objects.DisplayObject3D;

class FrustumClipping extends DefaultClipping
{
	public static var NONE 	:Int=0x0;
	public static var NEAR 	:Int=0x1;
	public static var LEFT 	:Int=0x2;
	public static var RIGHT	:Int=0x4;
	public static var TOP 	:Int=0x8;
	public static var BOTTOM 	:Int=0x10;
	public static var FAR 	:Int=0x20;
	
	public static inline var DEFAULT:Int=NEAR + LEFT + RIGHT + TOP + BOTTOM;
	public static var ALL 	:Int=DEFAULT + FAR;
	
	/**
	 * 
	 */ 
	public function new(planes:Int=-1)
	{	
		_cleft=Plane3D.fromCoefficients(0, 1, 0, 0);
		_cright=Plane3D.fromCoefficients(0, 1, 0, 0);
		_ctop=Plane3D.fromCoefficients(0, 1, 0, 0);
		_cbottom=Plane3D.fromCoefficients(0, 1, 0, 0);
		_cnear=Plane3D.fromCoefficients(0, 1, 0, 0);
		_cfar=Plane3D.fromCoefficients(0, 1, 0, 0);
		
		_wleft=Plane3D.fromCoefficients(0, 1, 0, 0);
		_wright=Plane3D.fromCoefficients(0, 1, 0, 0);
		_wtop=Plane3D.fromCoefficients(0, 1, 0, 0);
		_wbottom=Plane3D.fromCoefficients(0, 1, 0, 0);
		_wnear=Plane3D.fromCoefficients(0, 1, 0, 0);
		_wfar=Plane3D.fromCoefficients(0, 1, 0, 0);
		
		_nc=new Float3D();
		_fc=new Float3D();
		_ntl=new Float3D();
		_ntr=new Float3D();
		_nbr=new Float3D();
		_nbl=new Float3D();
		_ftl=new Float3D();
		_ftr=new Float3D();
		_fbr=new Float3D();
		_fbl=new Float3D();
		
		_camPos=new Float3D();
		_axisX=new Float3D();
		_axisY=new Float3D();
		_axisZ=new Float3D();
		_axisZi=new Float3D();
		
		_matrix=Matrix3D.IDENTITY;
		_world=Matrix3D.IDENTITY;
		_dynTriangles=new DynamicTriangles();
		
		this.planes=planes<0 ? DEFAULT:planes;
	}

	/**
	 * Bitmask indicating which planes are used for clipping.
	 */
	public var planes(get_planes, set_planes):Int;
 	private function get_planes():Int
	{
		return _planes;
	} 
	
	/**
	 * Bitmask indicating which planes are used for clipping.
	 */
	private function set_planes(value:Int):Void
	{
		_planes=value;
		
		_cplanes=new Array();
		_wplanes=new Array();
		_planePoints=new Array();
		
		if(_planes & NEAR)
		{
			_cplanes.push(_cnear);
			_wplanes.push(_wnear);
			_planePoints.push(_nc);
		}
		
		if(_planes & FAR)
		{
			_cplanes.push(_cfar);
			_wplanes.push(_wfar);
			_planePoints.push(_fc);
		}
		
		if(_planes & LEFT)
		{
			_cplanes.push(_cleft);
			_wplanes.push(_wleft);
			_planePoints.push(_camPos);
		}
		
		if(_planes & RIGHT)
		{
			_cplanes.push(_cright);
			_wplanes.push(_wright);
			_planePoints.push(_camPos);
		}
		
		if(_planes & TOP)
		{
			_cplanes.push(_ctop);
			_wplanes.push(_wtop);
			_planePoints.push(_camPos);
		}
		
		if(_planes & BOTTOM)
		{
			_cplanes.push(_cbottom);
			_wplanes.push(_wbottom);
			_planePoints.push(_camPos);
		}
	} 
	
	/**
	 * 
	 */ 	
	public override function reset(renderSessionData:RenderSessionData):Void
	{
		var camera	:CameraObject3D=renderSessionData.camera;
		
		var vpw:Float=renderSessionData.viewPort.viewportWidth;
		var vph:Float=renderSessionData.viewPort.viewportHeight;
		var tan:Float=Math.tan((camera.fov/2)* TO_RADIANS);
		var d:Float=camera.focus;
		
		_matrix.copy(renderSessionData.camera.transform);
		
		_axisX.reset(_matrix.n11, _matrix.n21, _matrix.n31);
		_axisY.reset(_matrix.n12, _matrix.n22, _matrix.n32);
		_axisZ.reset(_matrix.n13, _matrix.n23, _matrix.n33);
		_axisZi.reset(-_axisZ.x, -_axisZ.y, -_axisZ.z);

		var hnear:Float=2 * tan * d;
		var wnear:Float=hnear *(vpw/vph)

		_camPos.reset(camera.x, camera.y, camera.z);

		_nc.x=_camPos.x +(d * _axisZ.x);
		_nc.y=_camPos.y +(d * _axisZ.y);
		_nc.z=_camPos.z +(d * _axisZ.z);
		
		_fc.x=_camPos.x +(camera.far * _axisZ.x);
		_fc.y=_camPos.y +(camera.far * _axisZ.y);
		_fc.z=_camPos.z +(camera.far * _axisZ.z);
		
		_ntl.copyFrom(_nc);
		_nbl.copyFrom(_nc);
		_ntr.copyFrom(_nc);
		_nbr.copyFrom(_nc);
		
		hnear /=2;
		wnear /=2;
		
		_ntl.x -=wnear * _axisX.x;
		_ntl.y -=wnear * _axisX.y;
		_ntl.z -=wnear * _axisX.z;
		
		_ntl.x +=hnear * _axisY.x;
		_ntl.y +=hnear * _axisY.y;
		_ntl.z +=hnear * _axisY.z;
		
		_nbl.x -=wnear * _axisX.x;
		_nbl.y -=wnear * _axisX.y;
		_nbl.z -=wnear * _axisX.z;
		
		_nbl.x -=hnear * _axisY.x;
		_nbl.y -=hnear * _axisY.y;
		_nbl.z -=hnear * _axisY.z;
		
		_nbr.x +=wnear * _axisX.x;
		_nbr.y +=wnear * _axisX.y;
		_nbr.z +=wnear * _axisX.z;
		
		_nbr.x -=hnear * _axisY.x;
		_nbr.y -=hnear * _axisY.y;
		_nbr.z -=hnear * _axisY.z;
		
		_ntr.x +=wnear * _axisX.x;
		_ntr.y +=wnear * _axisX.y;
		_ntr.z +=wnear * _axisX.z;
		
		_ntr.x +=hnear * _axisY.x;
		_ntr.y +=hnear * _axisY.y;
		_ntr.z +=hnear * _axisY.z;
		
		if(_planes & NEAR)
		{
			_cnear.setNormalAndPoint(_axisZ, _nc);
		}
		
		if(_planes & FAR)
		{
			_cfar.setNormalAndPoint(_axisZi, _fc);
		}
		
		if(_planes & LEFT)
		{
			_cleft.setThreePoints(_camPos, _nbl, _ntl);
		}
		
		if(_planes & RIGHT)
		{
			_cright.setThreePoints(_camPos, _ntr, _nbr);
		}
		
		if(_planes & TOP)
		{
			_ctop.setThreePoints(_camPos, _ntl, _ntr);
		}
		
		if(_planes & BOTTOM)
		{
			_cbottom.setThreePoints(_camPos, _nbr, _nbl);
		}
		
		_dynTriangles.releaseAll();
	}
	
	/**
	 * 
	 */ 
	public override function setDisplayObject(object:DisplayObject3D, renderSessionData:RenderSessionData):Void
	{
		_world.copy(object.world);
		_world.invert();
		
		var pt:Float3D=new Float3D();
		
		for(i in 0..._cplanes.length)
		{
			var cplane:Plane3D=_cplanes[i];
			var wplane:Plane3D=_wplanes[i];
			
			pt.copyFrom(_planePoints[i]);
			wplane.normal.copyFrom(cplane.normal);

			Matrix3D.multiplyVector3x3(_world, wplane.normal);
			Matrix3D.multiplyVector(_world, pt);

			wplane.setNormalAndPoint(wplane.normal, pt);
		}
	}
	
	/**
	 * 
	 */ 
	public override function testFace(triangle:Triangle3D, object:DisplayObject3D, renderSessionData:RenderSessionData):Bool
	{
		for(i in 0..._wplanes.length)
		{
			var plane:Plane3D=_wplanes[i];
			
			var side:Int=ClassificationUtil.classifyTriangle(triangle, plane);
			
			if(side==ClassificationUtil.BACK || side==ClassificationUtil.COINCIDING)
			{
				return false;
			}
			else if(side==ClassificationUtil.STRADDLE)
			{
				return true;
			}
		}
		return false;
	}
	
	/**
	 * 
	 */
	public override function clipFace(triangle:Triangle3D, object:DisplayObject3D, material:MaterialObject3D, renderSessionData:RenderSessionData, outputArray:Array):Float 
	{
		var points	:Array<Dynamic>=[triangle.v0, triangle.v1, triangle.v2];
		var uvs		:Array<Dynamic>=[triangle.uv0, triangle.uv1, triangle.uv2];
		var clipped:Bool=false;
		
		for(i in 0..._wplanes.length)
		{
			var plane:Plane3D=_wplanes[i];
		
			var side:Int=ClassificationUtil.classifyPoints(points, plane);
			
			try
			{
				if(side==ClassificationUtil.STRADDLE)
				{
					points=clipPointsToPlane(triangle.instance, points, uvs, plane);
					clipped=true;
				}
			}
			catch(e:Dynamic)
			{
				PaperLogger.error("FrustumClipping#clipFace:" + e.message);
			}
		}
		
		if(!clipped)
		{
			outputArray.push(triangle);
			return 1;
		}
		
		var v0:Vertex3D=points[0];
		var t0:FloatUV=uvs[0];
		
		for(j in 1...points.length)
		{
			var k:Int=(j+1)% points.length;
			
			var v1:Vertex3D=points[j];
			var v2:Vertex3D=points[k];
			
			var t1:FloatUV=uvs[j];
			var t2:FloatUV=uvs[k];
			
			//var tri:Triangle3D=new Triangle3D(triangle.instance, [v0, v1, v2], triangle.material, [t0, t1, t2]);
			var tri:Triangle3D=_dynTriangles.getTriangle(triangle.instance, triangle.material, v0, v1, v2, t0, t1, t2);
			// make sure we got a valid triangle!
			if(tri.faceNormal.modulo)
			{
				outputArray.push(tri);
			}
		}
		
		return outputArray.length;
	}
	
	/**
	 * Sutherland-Hodgman clipping of an Array of points.
	 * 
	 * @param	points
	 * @param	plane
	 * @return
	 */
	public function clipPointsToPlane(object:DisplayObject3D, points:Array, uvs:Array, plane:Plane3D):Array
	{
		var verts:Array<Dynamic>=new Array();
		var texels:Array<Dynamic>=new Array();

		var dist1:Float=plane.distance(points[0]);
		
		for(j in 0...points.length)
		{
			var k:Int=(j+1)% points.length;
			
			var pt0:Vertex3D=points[j];
			var pt1:Vertex3D=points[k];
			
			var t0:FloatUV=uvs[j];
			var t1:FloatUV=uvs[k];
	
			var dist2:Float=plane.distance(pt1);
			var d:Float=dist1 /(dist1-dist2);
			var t:Vertex3D;
			var uv:FloatUV;
			
			var status:Int=compareDistances(dist1, dist2);
			
			switch(status)
			{
				case INSIDE:
					verts.push(pt1);
					texels.push(t1);
					break;
			
				case IN_OUT:
					t=new Vertex3D();
					t.x=pt0.x +(pt1.x - pt0.x)* d;
					t.y=pt0.y +(pt1.y - pt0.y)* d;
					t.z=pt0.z +(pt1.z - pt0.z)* d;
					
					uv=new FloatUV();
					uv.u=t0.u +(t1.u - t0.u)* d;
					uv.v=t0.v +(t1.v - t0.v)* d;
					texels.push(uv);
					
					verts.push(t);
					
					object.geometry.vertices.push(t);
					break;
				
				case OUT_IN:
					uv=new FloatUV();
					uv.u=t0.u +(t1.u - t0.u)* d;
					uv.v=t0.v +(t1.v - t0.v)* d;
					texels.push(uv);
					texels.push(t1);
					
					t=new Vertex3D();
					t.x=pt0.x +(pt1.x - pt0.x)* d;
					t.y=pt0.y +(pt1.y - pt0.y)* d;
					t.z=pt0.z +(pt1.z - pt0.z)* d;
					verts.push(t);
					verts.push(pt1);
					
					object.geometry.vertices.push(t);
					break;
						
				default:
					break;
			}
			dist1=dist2;
		}
		
		for(i in 0...texels.length)
		{
			uvs[i]=texels[i];
		}
		
		return verts;			
	}
	
	/**
	 * 
	 * @param	pDist1
	 * @param	pDist2
	 * @return
	 */
	private function compareDistances(pDist1:Float, pDist2:Float):Int
	{			
		if(pDist1<0 && pDist2<0)
			return OUTSIDE;
		else if(pDist1>0 && pDist2>0)
			return INSIDE;
		else if(pDist1>0 && pDist2<0)
			return IN_OUT;	
		else
			return OUT_IN;
	}	

	private static inline var OUTSIDE:Int=0;
	private static inline var INSIDE:Int=1;
	private static inline var OUT_IN:Int=2;
	private static inline var IN_OUT:Int=3;

	private static inline var TO_DEGREES:Float=180/Math.PI;
	private static inline var TO_RADIANS:Float=Math.PI/180;
	
	private var _planes		:Int;
	
	// frustum planes
	private var _cnear 		:Plane3D;
	private var _cfar 		:Plane3D;
	private var _ctop 		:Plane3D;
	private var _cbottom	:Plane3D;
	private var _cleft 		:Plane3D;
	private var _cright	 	:Plane3D;
	
	// frustum planes transformed by object's world matrix
	private var _wnear 		:Plane3D;
	private var _wfar 		:Plane3D;
	private var _wtop 		:Plane3D;
	private var _wbottom 	:Plane3D;
	private var _wleft 		:Plane3D;
	private var _wright	 	:Plane3D;
	
	// frustum geometry
	private var _nc			:Float3D;
	private var _fc			:Float3D;
	private var _ntl		:Float3D;
	private var _ntr		:Float3D;
	private var _nbr		:Float3D;
	private var _nbl		:Float3D;
	private var _ftl		:Float3D;
	private var _ftr		:Float3D;
	private var _fbr		:Float3D;
	private var _fbl		:Float3D;
	
	private var _camPos		:Float3D;
	private var _axisX		:Float3D;
	private var _axisY		:Float3D;
	private var _axisZ		:Float3D;
	private var _axisZi		:Float3D;
	
	private var _cplanes:Array<Dynamic>;
	private var _wplanes:Array<Dynamic>;
	
	private var _matrix	:Matrix3D;
	private var _world	:Matrix3D;
	
	private var _planePoints:Array<Dynamic>;
	private var _dynTriangles:DynamicTriangles;
}