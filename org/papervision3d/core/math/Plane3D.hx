package org.papervision3d.core.math;

import org.papervision3d.core.geom.renderables.Vertex3D;
import org.papervision3d.core.math.util.ClassificationUtil;

/**
* The Plane3D class represents a plane in 3D space.
* 
* @author Tim Knip
*/
class Plane3D
{
	private static var _yUP:Float3D=new Float3D(0, 1, 0);	
	private static var _zUP:Float3D=new Float3D(0, 0, 1);

	/**
	* The plane normal(A, B, C).
	*/
	public var normal:Float3D;

	/**
	 * D.
	 */
	public var d:Float;


	/**
	 * Constructor.
	 *
	 * @param	normal		The plane normal.
	 * @param	ptOnPlane	A point on the plane.
	 */
	public function new(normal:Float3D=null, ptOnPlane:Float3D=null)
	{
		if(normal && ptOnPlane)
		{
			this.normal=normal;
			this.d=-Number3D.dot(normal, ptOnPlane);
		}
		else
		{
			this.normal=new Float3D();
			this.d=0;	
		}
	}
	
	/**
	 * 
	 */ 
	public function clone():Plane3D
	{
		return Plane3D.fromCoefficients(this.normal.x, this.normal.y, this.normal.z, this.d);	
	}
	
	private var eps:Float=0.01;
	public function isCoplanar(plane:Plane3D):Bool
	{
		return(Math.abs(normal.x - plane.normal.x)<eps && Math.abs(normal.y - plane.normal.y)<eps && Math.abs(normal.z - plane.normal.z)<eps && Math.abs(d - plane.d)<eps);
	}
	
	protected static var flipPlane:Plane3D=new Plane3D();
	
	public function isCoplanarOpposite(plane:Plane3D):Bool
	{
		flipPlane.normal.z=-plane.normal.z;
		flipPlane.normal.y=-plane.normal.y;
		flipPlane.normal.x=-plane.normal.x;
		flipPlane.d=plane.d;
		return flipPlane.isCoplanar(plane);
	}
	
	public function getFlip():Plane3D
	{
		var plane:Plane3D=Plane3D.fromThreePoints(new Float3D(), new Float3D(), new Float3D());
		plane.normal.z=-normal.z;
		plane.normal.y=-normal.y;
		plane.normal.x=-normal.x;
		plane.d=d;
		
		return plane;
	}
	
	public function getTempFlip():Plane3D
	{
		flipPlane.normal.z=-normal.z;
		flipPlane.normal.y=-normal.y;
		flipPlane.normal.x=-normal.x;
		flipPlane.d=d;
		return flipPlane;
	}
	
	public function getIntersectionLineNumbers(v0:Float3D, v1:Float3D):Float3D
	{
		var d0:Float=normal.x * v0.x + normal.y * v0.y + normal.z * v0.z - d;
		var d1:Float=normal.x * v1.x + normal.y * v1.y + normal.z * v1.z - d;
		var m:Float=d1 /(d1 - d0);
		
		return new Float3D(

				v1.x +(v0.x - v1.x)* m,

				v1.y +(v0.y - v1.y)* m,

				v1.z +(v0.z - v1.z)* m

			);

	}
	
	public function getIntersectionLine(v0:Vertex3D, v1:Vertex3D):Vertex3D
	{
		var d0:Float=normal.x * v0.x + normal.y * v0.y + normal.z * v0.z - d;
		var d1:Float=normal.x * v1.x + normal.y * v1.y + normal.z * v1.z - d;
		var m:Float=d1 /(d1 - d0);
		return new Vertex3D(

				v1.x +(v0.x - v1.x)* m,

				v1.y +(v0.y - v1.y)* m,

				v1.z +(v0.z - v1.z)* m

			);

	}
	
	/**
	 * Creates a plane from coefficients.
	 *
	 * @param	a
	 * @param	b
	 * @param	c
	 * @param	d
	 *
	 * @return	The created plane.
	 */
	public static function fromCoefficients(a:Float, b:Float, c:Float, d:Float):Plane3D
	{
		var plane:Plane3D=new Plane3D();
		plane.setCoefficients(a, b, c, d);
		return plane;
	}
	
	/**
	 * Creates a plane from a normal and a point.
	 *
	 * @param	normal
	 * @param	point
	 *
	 * @return	The created plane.
	 */
	public static function fromNormalAndPoint(normal:Dynamic, point:Dynamic):Plane3D 
	{
		var n:Float3D=normal is Float3D ? normal:new Float3D(normal.x, normal.y, normal.z);
		var p:Float3D=point is Float3D ? point:new Float3D(point.x, point.y, point.z);
		return new Plane3D(n, p);
	}
	
	/**
	 * Creates a plane from three points.
	 *
	 * @param	p0	First point.
	 * @param	p1	Second point.
	 * @param	p2	Third point.
	 *
	 * @return	The created plane.
	 */
	public static function fromThreePoints(p0:Dynamic, p1:Dynamic, p2:Dynamic):Plane3D
	{
		var plane:Plane3D=new Plane3D();
		var n0:Float3D=p0 is Float3D ? p0:new Float3D(p0.x, p0.y, p0.z);
		var n1:Float3D=p1 is Float3D ? p1:new Float3D(p1.x, p1.y, p1.z);
		var n2:Float3D=p2 is Float3D ? p2:new Float3D(p2.x, p2.y, p2.z);
		
		plane.setThreePoints(n0, n1, n2);
		return plane;
	}
	
	/**
	 * Get the closest point on the plane.
	 *
	 * @param	point		The point to 'project'.
	 * @param 	ptOnPlane	A known point on the plane.
	 */
	public function closestPointOnPlane(point:Float3D, ptOnPlane:Float3D):Float3D
	{
		var dist:Float=Number3D.dot(this.normal, Float3D.sub(point, ptOnPlane));
		var ret:Float3D=point.clone();
		ret.x -=(dist * this.normal.x);
		ret.y -=(dist * this.normal.y);
		ret.z -=(dist * this.normal.z);
		return ret;
	}
	
	/**
	 * distance of point to plane.
	 * 
	 * @param	v
	 * @return
	 */
	public function distance(pt:Dynamic):Float
	{
		var p:Float3D=pt is Vertex3D ? pt.toNumber3D():pt;
		return Float3D.dot(p, normal)+ d;
	}
	
	/**
	 * distance of vertex to plane, optimized.
	 * 
	 * @param	v
	 * @return
	 */
	
	public function vertDistance(pt:Vertex3D):Float
	{
		return(pt.x * normal.x + normal.y * pt.y + pt.z * normal.z)+d;
	}
	
	/**
	 * normalize.
	 * 
	 * @return
	 */
	public function normalize():Void
	{
		var n:Float3D=this.normal;
		
		//compute the length of the vector
		var len:Float=Math.sqrt(n.x*n.x + n.y*n.y + n.z*n.z);
		
		// normalize
		n.x /=len;
		n.y /=len;
		n.z /=len;
		this.d /=len;
	}
	
	/**
	 * Sets this plane from ABCD coefficients.
	 *
	 * @param	a
	 * @param	b
	 * @param	c
	 * @param	d
	 */
	public function setCoefficients(a:Float, b:Float, c:Float, d:Float):Void
	{
		// set the normal vector
		this.normal.x=a;
		this.normal.y=b;
		this.normal.z=c;
		this.d=d;
		
		normalize();
	}
	
	/**
	 * Sets this plane from a normal and a point.
	 *
	 * @param	normal
	 * @param	pt
	 */
	public function setNormalAndPoint(normal:Float3D, pt:Float3D):Void
	{
		this.normal=normal;
		this.d=-Number3D.dot(normal, pt);
	}
	
	/**
	 * Sets this plane from three points.
	 *
	 * @param	p0
	 * @param	p1
	 * @param	p2
	 */
	public function setThreePoints(p0:Float3D, p1:Float3D, p2:Float3D):Void
	{				
		var ab:Float3D=Number3D.sub(p1, p0);
		var ac:Float3D=Number3D.sub(p2, p0);
		this.normal=Number3D.cross(ab, ac);
		this.normal.normalize();
		this.d=-Number3D.dot(normal, p0);
	}
	
	
	/**
	 * Gets the side a vertex is on.
	 */
	 public function pointOnSide(num:Float3D):Int
	 {
	 	var distance:Float=distance(num);
		if(distance<0){
			return ClassificationUtil.BACK;
		}else if(distance>0){
			return ClassificationUtil.FRONT;
		}
		return ClassificationUtil.COINCIDING;
	 }
	
	/**
	 * Projects points onto this plane. 
	 *<p>Passed points should be in the XY-plane. If the points have Z=0 then the points are
	 * projected exactly on the plane. When however Z is greater then zero, the points are
	 * moved 'out of the plane' by a distance Z. Negative values for Z move the points 'into the plane'.</p>
	 *
	 * @param	points	Array of points(any object with x, y, z props).
	 * @param	origin	Where to move the points.
	 */
	public function projectPoints(points:Array, origin:Float3D=null):Void {

		// use other up-vector if angle between plane-normal and up-vector approaches zero.
		var dot:Float=Number3D.dot(_yUP, this.normal);
		
		// when the dot-product approaches 1 the angle approaches 0
		var up:Float3D=Math.abs(dot)>0.99 ? _zUP:_yUP;
		
		// get side vector
		var side:Float3D=Number3D.cross(up, normal);
		side.normalize();

		// adjust up vector
		up=Number3D.cross(normal, side);
		up.normalize();
		
		// create the matrix!
		var matrix:Matrix3D=new Matrix3D([
			side.x, up.x, normal.x, 0,
			side.y, up.y, normal.y, 0,
			side.z, up.z, normal.z, 0,
			0, 0, 0, 1]);
		
		// translate if wanted	
		if(origin)
			matrix=Matrix3D.multiply(Matrix3D.translationMatrix(origin.x, origin.y, origin.z), matrix);
		
		// project!
		var n:Float3D=new Float3D();
		for(var point:Dynamic in points){
			n.x=point["x"];
			n.y=point["y"];
			n.z=point["z"];
			
			Matrix3D.multiplyVector(matrix, n);
			
			point["x"]=n.x;
			point["y"]=n.y;
			point["z"]=n.z;
		}
	}
	
	public function toString():String
	{
		return "[a:" + normal.x  +" b:" +normal.y + " c:" +normal.z + " d:" + d + "]";
	}

	
}