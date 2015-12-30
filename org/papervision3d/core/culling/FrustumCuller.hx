package org.papervision3d.core.culling;

import org.papervision3d.core.geom.renderables.Vertex3D;
import org.papervision3d.core.math.AxisAlignedBoundingBox;
import org.papervision3d.core.math.BoundingSphere;
import org.papervision3d.core.math.Matrix3D;
import org.papervision3d.core.math.Number3D;
import org.papervision3d.objects.DisplayObject3D;

/**
 * @author Tim Knip
 */ 
class FrustumCuller implements IObjectCuller
{
	public static inline var INSIDE:Int=1;
	public static inline var OUTSIDE:Int=-1;
	public static inline var INTERSECT:Int=0;
	
	/** */
	public var transform	:Matrix3D;

	/**
	 * Constructor.
	 */ 
	public function new()
	{
		this.transform=Matrix3D.IDENTITY;
		
		this.initialize();
	}
	
	/**
	 * Intializes the frustum.
	 * 
	 * @param	fovY	Vertical Field Of View in degrees.
	 * @param	ratio	Aspect ratio(ie:viewport.width / viewport.height).
	 * @param	near	Distance to near plane(ie:camera.focus).
	 * @param	far		Distance to far plane.
	 */ 
	public function initialize(fovY:Float=60, ratio:Float=1.333, near:Float=1, far:Float=5000):Void
	{
		// store the information
		_fov=fovY;
		_ratio=ratio;
		_near=near;
		_far=far;

		var angle:Float=(Math.PI/180)* _fov * 0.5;
		
		// compute width and height of the near and far section
		_tang=Math.tan(angle);
		_nh=_near * _tang;
		_nw=_nh * _ratio;
		_fh=_far * _tang;
		_fw=_fh * _ratio;
	
		var anglex:Float=Math.atan(_tang * _ratio);
	
		// used for bounding-sphere culling
		_sphereX=1.0 / Math.cos(anglex);		
		_sphereY=1.0 / Math.cos(angle);
	}
	
	/**
	 * Tests whether an axis aligned boundingbox is inside, outside or Intersecting the frustum. 
	 * When earlyOut is set to true, the method returns INSIDE when a single point of the aabb is
	 * inside the frustum(fast). Set earlyOut to false if you want to test for INTERSECT. 
	 * 
	 * @param	object	The object to test.
	 * @param	aabb	AxisAlignedBoundingBox.
	 * @param	earlyOut	Early out. Default is true.
	 * 
	 * @return Integer indicating inside(1), outside(-1)or Intersecting(0)the frustum.
	 */
	public function aabbInFrustum(object:DisplayObject3D, aabb:AxisAlignedBoundingBox, earlyOut:Bool=true):Int
	{
		var vertex:Vertex3D;
		var num:Float3D;
		var numInside:Int=0;
		var numOutside:Int=0;
		var vertices:Array<Dynamic>=aabb.getBoxVertices();
		
		// Transform the boundingbox to world and test...
		for(vertex in vertices)
		{
			num=vertex.toNumber3D();
			Matrix3D.multiplyVector(object.world, num);
			if(pointInFrustum(num.x, num.y, num.z)==INSIDE)
			{
				numInside++;
				if(earlyOut)
					return INSIDE;	
			}
			else
				numOutside++;
			
			// aabb has points both inside and outside the frustum, must be Intersecting.
			if(numInside && numOutside)
				return INTERSECT;
		}
			
		if(numInside)
			return(numInside<8 ? INTERSECT:INSIDE);
		else
			return OUTSIDE;
	}
	
	/**
	 * Tests whether a point is inside the frustum.
	 *
	 * @param 	x
	 * @param 	y
	 * @param 	z
	 *
	 * @return	Integer indicating inside(1)or outside(-1)the frustum.
	 */
	public function pointInFrustum(x:Float, y:Float, z:Float):Int
	{
		var m	:Matrix3D=this.transform;
		
		// compute vector from camera position to p
		var px	:Float=x - m.n14;
		var py	:Float=y - m.n24;
		var pz	:Float=z - m.n34;
		
		// compute and test the Z coordinate
		var pcz:Float=px * m.n13 + py * m.n23 + pz * m.n33;
		if(pcz>_far || pcz<_near)
			return OUTSIDE;
		
		// compute and test the Y coordinate
		var pcy:Float=px * m.n12 + py * m.n22 + pz * m.n32;
		var aux:Float=pcz * _tang;
		if(pcy>aux || pcy<-aux)
			return OUTSIDE;

		// compute and test the X coordinate
		var pcx:Float=px * m.n11 + py * m.n21 + pz * m.n31;
		aux=aux * _ratio;
		if(pcx>aux || pcx<-aux)
			return OUTSIDE;
		
		return INSIDE;
	}
	
	/**
	 * Tests whether a sphere is inside the frustum.
	 *
	 * @param 	object	The object to test.
	 * @param	boundingSphere	The bounding sphere.
	 *
	 * @return	Integer indicating inside(1), outside(0)or Intersecting(-1)the frustum.
	 */
	public function sphereInFrustum(obj:DisplayObject3D, boundingSphere:BoundingSphere):Int
	{
		var radius:Float=boundingSphere.radius * Math.max(obj.scaleX, Math.max(obj.scaleY, obj.scaleZ));
		var d:Float;
		var ax:Float;
		var ay:Float;
		var az:Float;
		var result:Int=INSIDE;
	
		var m:Matrix3D=this.transform;

		// compute vector from camera position to p
		var px:Float=obj.world.n14 - m.n14;
		var py:Float=obj.world.n24 - m.n24;
		var pz:Float=obj.world.n34 - m.n34;
		
		// near and far
		az=px * m.n13 + py * m.n23 + pz * m.n33;
		if(az>_far + radius || az<_near-radius)
			return OUTSIDE;			
		if(az>_far - radius || az<_near+radius)
			result=INTERSECT;

		// top and bottom
		ay=px * m.n12 + py * m.n22 + pz * m.n32;
		d=_sphereY * radius;
		az *=_tang;
		if(ay>az+d || ay<-az-d)
			return OUTSIDE;
		if(ay>az-d || ay<-az+d)
			result=INTERSECT;

		// left and right
		ax=px * m.n11 + py * m.n21 + pz * m.n31;
		az *=_ratio;
		d=_sphereX * radius;
		if(ax>az+d || ax<-az-d)
			return OUTSIDE;
		if(ax>az-d || ax<-az+d)
			result=INTERSECT;
			
		return result;
	}
	
	/**
	 * Tests whether an object is inside the frustum.
	 * 
	 * @param	obj		The object to test
	 * 
	 * @return	Integer indicating inside(1), outside(-1)or Intersecting(0)
	 */
	public function testObject(obj:DisplayObject3D):Int
	{	
		var result	:Int=INSIDE;
		
		if(!obj.geometry || !obj.geometry.vertices || !obj.geometry.vertices.length)
			return result;	
		
		switch(obj.frustumTestMethod)
		{
			case FrustumTestMethod.BOUNDING_SPHERE:
				result=sphereInFrustum(obj, obj.geometry.boundingSphere);
				break;
			case FrustumTestMethod.BOUNDING_BOX:
				result=aabbInFrustum(obj, obj.geometry.aabb);
				break;
			case FrustumTestMethod.NO_TESTING:
				break;
			default:
				break;	
		}

		return result;
	}
	
	private function set_far(value:Float):Void
	{
		this.initialize(_fov, _ratio, _near, value);
	}
	
	public var far(get_far, set_far):Float;
 	private function get_far():Float
	{
		return _far;
	}
	
	private function set_fov(value:Float):Void
	{
		this.initialize(value, _ratio, _near, _far);
	}
	
	public var fov(get_fov, set_fov):Float;
 	private function get_fov():Float
	{
		return _fov;
	}
	
	private function set_near(value:Float):Void
	{
		this.initialize(_fov, _ratio, value, _far);
	}
	
	public var near(get_near, set_near):Float;
 	private function get_near():Float
	{
		return _near;
	}
	
	private function set_ratio(value:Float):Void
	{
		this.initialize(_fov, value, _near, _far);
	}
	
	public var ratio(get_ratio, set_ratio):Float;
 	private function get_ratio():Float
	{
		return _ratio;
	}
	
	private var _fov		:Float;
	private var _far		:Float;
	private var _near		:Float;
	private var _nw			:Float;
	private var _nh			:Float;
	private var _fw			:Float;
	private var _fh			:Float;
	private var _tang		:Float;
	private var _ratio  	:Float;
	private var _sphereX 	:Float;
	private var _sphereY	:Float;
}