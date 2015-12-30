package org.papervision3d.core.proto;

import flash.geom.Rectangle;

import org.papervision3d.Papervision3D;
import org.papervision3d.core.culling.IObjectCuller;
import org.papervision3d.core.log.PaperLogger;
import org.papervision3d.core.math.Matrix3D;
import org.papervision3d.core.math.Number3D;
import org.papervision3d.core.math.util.GLU;
import org.papervision3d.core.render.data.RenderSessionData;
import org.papervision3d.objects.DisplayObject3D;

/**
* The CameraObject3D class is the base class for all the cameras that can be placed in a scene.
*<p/>
* A camera defines the view from which a scene will be rendered. Different camera settings would present a scene from different points of view.
*<p/>
* 3D cameras simulate still-image, motion picture, or video cameras of the real world. When rendering, the scene is drawn as if you were looking through the camera lens.
*/
class CameraObject3D extends DisplayObject3D
{
	// __________________________________________________________________________
	//

	/**
	* This value specifies the scale at which the 3D objects are rendered. Higher values magnify the scene, compressing distance. Use it in conjunction with focus.
	*/
	public var zoom:Float;


	/**
	* This value is a positive number representing the distance of the observer from the front clipping plane, which is the closest any object can be to the camera. Use it in conjunction with zoom.
	*<p/>
	* Higher focus values tend to magnify distance between objects while allowing greater depth of field, as if the camera had a wider lenses. One result of using a wide angle lens in proximity to the subject is an apparent perspective distortion:parallel lines may appear to converge and with a fisheye lens, straight edges will appear to bend.
	*<p/>
	* Different lenses generally require a different camera to subject distance to preserve the size of a subject. Changing the angle of view can indirectly distort perspective, modifying the apparent relative size of the subject and foreground.
	*/
	public var focus:Float;


	/**
	* A Bool value that determines whether the 3D objects are z-depth sorted between themselves when rendering.
	*/
	public var sort:Bool;
	 
	/** 
	*  
	*/
	public var eye	:Matrix3D;
	
	/**
	* 
	*/
	public var viewport	:Rectangle;
	
	/** 
	 * 
	 */
	public var culler	:IObjectCuller;
	
	/**
	 * 
	 */
	public var yUP:Bool;
	 
	/**
	 * The default position for new cameras.
	 */
	public static var DEFAULT_POS:Float3D=new Float3D(0, 0, -1000);

	/**
	 * The default UP vector for new cameras.
	 */ 
	public static var DEFAULT_UP:Float3D=new Float3D(0, 1, 0);
	
	/** 
	 * The default viewport for new cameras.
	 */
	public static var DEFAULT_VIEWPORT:Rectangle=new Rectangle(0, 0, 550, 400);
	
	
	// __________________________________________________________________________
	//																	  N E W
	// NN  NN EEEEEE WW	WW
	// NNN NN EE	 WW WW WW
	// NNNNNN EEEE   WWWWWWWW
	// NN NNN EE	 WWW  WWW
	// NN  NN EEEEEE WW	WW

	/**
	* The CameraObject3D constructor lets you create cameras for setting up the view from which a scene will be rendered.
	*
	* @param	focus		This value is a positive number representing the distance of the observer from the front clipping plane, which is the closest any object can be to the camera. Use it in conjunction with zoom.
	*<p/>
	* @param	zoom		This value specifies the scale at which the 3D objects are rendered. Higher values magnify the scene, compressing distance. Use it in conjunction with focus.
	*<p/>
	*/
	public function new(focus:Float=500, zoom:Float=3)
	{
		super();

		this.x=DEFAULT_POS.x;
		this.y=DEFAULT_POS.y;
		this.z=DEFAULT_POS.z;
		
		this.zoom=zoom;
		this.focus=focus;
		this.eye=Matrix3D.IDENTITY;
		this.viewport=DEFAULT_VIEWPORT;
		this.sort=true;
		
		_ortho=false;
		_orthoScaleMatrix=Matrix3D.scaleMatrix(1, 1, 1);
		
		if(Papervision3D.useRIGHTHANDED)
		{
			DEFAULT_UP.y=-1;
			this.yUP=false;
			this.lookAt(DisplayObject3D.ZERO);
		}
		else
			this.yUP=true;
	}
	
	/**
	 * Lookat.
	 * 
	 * @param targetObject
	 * @param upAxis
	 */ 
	public override function lookAt(targetObject:DisplayObject3D, upAxis:Float3D=null):Void
	{
		if(this.yUP)
		{
			super.lookAt(targetObject, upAxis);
		}	
		else
		{
			super.lookAt(targetObject, upAxis || DEFAULT_UP);
		}
	}
	
	/**
	 * Orbits the camera around the specified target. If no target is specified the 
	 * camera's #target property is used. If this camera's #target property equals null
	 * the camera orbits the origin(0, 0, 0).
	 * 
	 * @param	pitch	Rotation around X=axis(looking up or down).
	 * @param	yaw		Rotation around Y-axis(looking left or right).
	 * @param	useDegrees 	Whether to use degrees for pitch and yaw(defaults to 'true').
	 * @param	target	An optional target to orbit around.
	 */ 
	public function orbit(pitch:Float, yaw:Float, useDegrees:Bool=true, target:DisplayObject3D=null):Void
	{
	}
	
	/**
	 * Projects vertices.
	 * 
	 * @param	object
	 * @param	renderSessionData
	 */ 
	public function projectVertices(vertices:Array, object:DisplayObject3D, renderSessionData:RenderSessionData):Float
	{	
		return 0;
	}
	
	public function projectFaces(faces:Array, object:DisplayObject3D, renderSessionData:RenderSessionData):Float{
		return 0;
	}
	
	// ___________________________________________________________________________________________________
	//																				   T R A N S F O R M
	// TTTTTT RRRRR	AA   NN  NN  SSSSS FFFFFF OOOO  RRRRR  MM   MM
	//   TT   RR  RR  AAAA  NNN NN SS	 FF	OO  OO RR  RR MMM MMM
	//   TT   RRRRR  AA  AA NNNNNN  SSSS  FFFF  OO  OO RRRRR  MMMMMMM
	//   TT   RR  RR AAAAAA NN NNN	 SS FF	OO  OO RR  RR MM M MM
	//   TT   RR  RR AA  AA NN  NN SSSSS  FF	 OOOO  RR  RR MM   MM

	/**
	* [internal-use] Transforms world coordinates Into camera space.
	*/
	// TODO:OPTIMIZE(LOW)Resolve + inline
	public function transformView(transform:Matrix3D=null):Void
	{
		if(this.yUP)
		{
			eye.calculateMultiply(transform || this.transform, _flipY);
			eye.invert();
		}
		else
		{
			eye.calculateInverse(transform || this.transform);
		}
	}

	static private var _flipY:Matrix3D=Matrix3D.scaleMatrix(1, -1, 1);


	/**
	* Rotate the camera in its vertical plane.
	*<p/>
	* Tilting the camera results in a motion similar to someone nodding their head "yes".
	*
	* @param	angle	Angle to tilt the camera.
	*/
	public function tilt(angle:Float):Void
	{
		//if(!_target)
		//	super.pitch(angle);
	}

	/**
	* Rotate the camera in its horizontal plane.
	*<p/>
	* Panning the camera results in a motion similar to someone shaking their head "no".
	*
	* @param	angle	Angle to pan the camera.
	*/
	public function pan(angle:Float):Void
	{
	//	if(_target)
	//		super.yaw(angle);
	}
	
	/**
	 * Unproject.
	 * 
	 * @param	mX
	 * @param	mY
	 */ 
	public function unproject(mX:Float, mY:Float, mZ:Float=0):Float3D
	{	
		var vector:Float3D;
		
		if(_useProjectionMatrix)
		{
			if(!viewport)
			{
				return null;
			}
			
			var m:Matrix3D=this.transform;
			var vp:Array<Dynamic>=[
				-viewport.width/2,
				-viewport.height/2,
				viewport.width,
				viewport.height
			];
			
			// need transposed transform for GLU
			var world:Array<Dynamic>=[
				m.n11, m.n21, m.n31, m.n41,
				m.n12, m.n22, m.n32, m.n42,
				m.n13, m.n23, m.n33, m.n43,
				m.n14, m.n24, m.n34, m.n44
			];
			var projection:Array<Dynamic>=new Array(16);
			var out:Array<Dynamic>=new Array(4);
			 
			GLU.invertMatrix(world, world);
			if(_ortho)
			{
				var scale:Array<Dynamic>=new Array(16);
				var tmp:Array<Dynamic>=new Array(16);
				
				GLU.ortho(tmp, viewport.width/2, -viewport.width/2, -viewport.height/2, viewport.height/2, far, near);
				GLU.scale(scale, _orthoScale, _orthoScale, 1);
				GLU.multMatrices(scale, tmp, projection);
			}
			else
			{
				GLU.perspective(projection, fov, viewport.width/viewport.height, -near, -far);
			}
			GLU.unProject(-mX, mY, mZ, world, projection, vp, out);
			
			vector=new Float3D();
			vector.x=out[0];
			vector.y=out[1];
			vector.z=out[2];
		}
		else
		{
			var persp:Float=(focus*zoom)/(focus);
			
			vector=new Float3D(mX/persp,(yUP?-mY:mY)/persp, focus);

			Matrix3D.multiplyVector3x3(transform, vector);
		}
		return vector;
	}
	
	/**
	 * Sets the vertical Field Of View in degrees.
	 * 
	 * @param	degrees
	 */ 
	private function set_fov(degrees:Float):Void
	{
		if(!viewport || viewport.isEmpty())
		{
			PaperLogger.warning("CameraObject3D#viewport not set, can't set fov!");
			return;
		}
		
		var tx	:Float=0;
		var ty	:Float=0;
		var tz	:Float=0;
		
		if(_target)
		{
			tx=_target.world.n14;
			ty=_target.world.n24;
			tz=_target.world.n34;
		}
		
		//var vx	:Float=this.x - tx;
		//var vy	:Float=this.y - ty;
		//var vz	:Float=this.z - tz;

		var h:Float=viewport.height / 2;
		//var d:Float=Math.sqrt(vx*vx + vy*vy + vz*vz)+ this.focus;
		//var r:Float=180 / Math.PI;
		
		var vfov:Float=(degrees/2)*(Math.PI/180);
		
		this.focus=(h / Math.tan(vfov))/ this.zoom;
	}
	
	/**
	 * Gets the vertical Field Of View in degrees.
	 */ 
	public var fov(get_fov, set_fov):Float;
 	private function get_fov():Float
	{
		if(!viewport || viewport.isEmpty())
		{
			PaperLogger.warning("CameraObject3D#viewport not set, can't calculate fov!");
			return NaN;
		}
			
		var tx	:Float=0;
		var ty	:Float=0;
		var tz	:Float=0;
		
		if(_target)
		{
			tx=_target.world.n14;
			ty=_target.world.n24;
			tz=_target.world.n34;
		}
		
		var vx	:Float=this.x - tx;
		var vy	:Float=this.y - ty;
		var vz	:Float=this.z - tz;
		
		var f	:Float=this.focus;
		var z	:Float=this.zoom;
		var d	:Float=Math.sqrt(vx*vx + vy*vy + vz*vz)+ f;	// distance along camera's z-axis
		var h	:Float=viewport.height / 2;
		var r	:Float=(180/Math.PI);
		
		return Math.atan((((d / f)/ z)* h)/ d)* r * 2;
	}

	/**
	 * Gets the distance to the far plane.
	 */ 
	public var far(get_far, set_far):Float;
 	private function get_far():Float
	{
		return _far;
	}
	
	/**
	 * Sets the distance to the far plane.
	 * 
	 * @param	value
	 */ 
	private function set_far(value:Float):Void
	{
		if(value>this.focus)
		{
			_far=value;
		}
	}
	
	/**
	 * Gets the distance to the near plane(note that this simply is an alias for #focus).
	 */ 
	public var near(get_near, set_near):Float;
 	private function get_near():Float
	{
		return this.focus;
	}
	
	/**
	 * Sets the distance to the near plane(note that this is simply an alias for #focus).
	 * 
	 * @param	value
	 */  
	private function set_near(value:Float):Void
	{
		if(value>0)
		{
			this.focus=value;
		}
	}
	
	/**
	 * Gets the target for this camera, if any.
	 * 
	 * @return DisplayObject3D
	 */ 
	public var target(get_target, set_target):DisplayObject3D;
 	private function get_target():DisplayObject3D
	{
		return _target;	
	}
	
	/**
	 * Sets the target for this camera.
	 * 
	 * @param	object	A DisplayObject3D
	 */
	private function set_target(object:DisplayObject3D):Void
	{
		_target=object;
	}
	
	/**
	 * Whether this camera uses culling.
	 * 
	 * @return Bool
	 */ 
	public var useCulling(get_useCulling, set_useCulling):Bool;
 	private function get_useCulling():Bool
	{
		return _useCulling;	
	}
	
	/**
	 * Whether this camera uses culling.
	 */ 
	private function set_useCulling(value:Bool):Void
	{
		_useCulling=value;
	}
	
	/**
	 * Whether this camera uses a projection matrix.
	 * 
	 * @return Bool
	 */ 
	public var useProjectionMatrix(get_useProjectionMatrix, set_useProjectionMatrix):Bool;
 	private function get_useProjectionMatrix():Bool
	{
		return _useProjectionMatrix;
	}
	
	/**
	 * Whether this camera uses a projection matrix.
	 */
	private function set_useProjectionMatrix(value:Bool):Void
	{
		_useProjectionMatrix=value;
	}
	
	/**
	 * Whether the camera uses orthographic projection.
	 */
	public var ortho(get_ortho, set_ortho):Bool;
 	private function get_ortho():Bool
	{
		return _ortho;
	}
	
	/**
	 * Whether the camera uses orthographic projection.
	 */ 
	private function set_ortho(value:Bool):Void
	{
		_ortho=value;
	}
	
	/**
	 * The scale of projection when in orthographic mode.
	 */ 
	public var ortho(get_ortho, set_ortho):Bool;
 	private function get_orthoScale():Float
	{
		return _orthoScale;
	}
	
	/**
	 * The scale of projection when in orthographic mode.
	 */ 
	private function set_orthoScale(value:Float):Void
	{
		_orthoScale=value>0 ? value:0.0001;
		
		_orthoScaleMatrix.n11=_orthoScale;
		_orthoScaleMatrix.n22=_orthoScale;
		_orthoScaleMatrix.n33=_orthoScale;
	}
	
	private var _useCulling			:Bool;
	private var _useProjectionMatrix	:Bool;
	private var _ortho				:Bool;
	private var _orthoScale 			:Float=1;
	private var _orthoScaleMatrix 	:Matrix3D;
	private var _target				:DisplayObject3D;
	private var _far					:Float;
}