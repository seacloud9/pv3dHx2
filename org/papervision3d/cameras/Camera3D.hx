package org.papervision3d.cameras;

import flash.geom.Rectangle;
import flash.utils.getTimer;

import org.papervision3d.core.culling.FrustumCuller;
import org.papervision3d.core.geom.renderables.Triangle3D;
import org.papervision3d.core.geom.renderables.Vertex3D;
import org.papervision3d.core.geom.renderables.Vertex3DInstance;
import org.papervision3d.core.math.Matrix3D;
import org.papervision3d.core.proto.CameraObject3D;
import org.papervision3d.core.render.data.RenderSessionData;
import org.papervision3d.objects.DisplayObject3D;

/**
 * Camera3D is the basic camera used by Papervision3D.
 *</p>
 * 
 * @author Tim Knip
 */ 
class Camera3D extends CameraObject3D
{	
	/**
	 * Constructor.
	 * 
	 * @param	fov		This value is the vertical Field Of View(FOV)in degrees.
	 * @param	near	Distance to the near clipping plane.
	 * @param	far		Distance to the far clipping plane.
	 * @param	useCulling		Boolean indicating whether to use frustum culling. When true all objects outside the view will be culled.
	 * @param	useProjection 	Boolean indicating whether to use a projection matrix for perspective.
	 */ 
	public function new(fov:Float=60, near:Float=10, far:Float=5000, useCulling:Bool=false, useProjection:Bool=false)
	{
		super(near, 40);
		
		this.fov=fov;
		
		_prevFocus=0;
		_prevZoom=0;
		_prevOrtho=false;
		_prevUseProjection=false;
		_useCulling=useCulling;
		_useProjectionMatrix=useProjection;
		_far=far;
		_focusFix=Matrix3D.IDENTITY;
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
	public override function orbit(pitch:Float, yaw:Float, useDegrees:Bool=true, target:DisplayObject3D=null):Void
	{
		target=target || _target;
		target=target || DisplayObject3D.ZERO;

		if(useDegrees)
		{
			pitch *=(Math.PI/180);
			yaw *=(Math.PI/180);
		}
		
		// Float3D.sub
		var dx 			:Float=target.world.n14 - this.x;
		var dy 			:Float=target.world.n24 - this.y;
		var dz 			:Float=target.world.n34 - this.z;
		
		// Float3D.modulo
		var distance 	:Float=Math.sqrt(dx*dx+dy*dy+dz*dz);

		// Rotations
		var rx:Float=Math.cos(yaw)* Math.sin(pitch);
		var rz:Float=Math.sin(yaw)* Math.sin(pitch);
		var ry:Float=Math.cos(pitch);
		
		// Move to specified location
		this.x=target.world.n14 +(rx * distance);
		this.y=target.world.n24 +(ry * distance);
		this.z=target.world.n34 +(rz * distance);
		
		this.lookAt(target);
	}
	
	public override function projectFaces(faces:Array, object:DisplayObject3D, renderSessionData:RenderSessionData):Float{
			
	/* 	 
		//alternative way - less code but slower
		
		var vertices:Array<Dynamic>=[];
		var uniques:Dictionary=new Dictionary(true);
		
		for(var f:Triangle3D in faces){
			for(var v:Vertex3D in f.vertices){
				if(!uniques[v]){
					vertices.push(v);
					uniques[v]=true;
				}
			} 
			//vertices.push(f.v0, f.v1, f.v2);
		}	
		
		return projectVertices(vertices, object, renderSessionData);*/
		
		var view		:Matrix3D=object.view,
			m11 		:Float=view.n11,
			m12 		:Float=view.n12,
			m13 		:Float=view.n13,
			m21 		:Float=view.n21,
			m22 		:Float=view.n22,
			m23 		:Float=view.n23,
			m31 		:Float=view.n31,
			m32 		:Float=view.n32,
			m33 		:Float=view.n33,
			m41 		:Float=view.n41,
			m42 		:Float=view.n42,
			m43 		:Float=view.n43,
			vx			:Float,
			vy			:Float,
			vz			:Float,
			s_x			:Float,
			s_y			:Float,
			s_z			:Float,
			s_w			:Float,
			vertex		:Vertex3D, 
			screen		:Vertex3DInstance,
			persp 		:Float,
			i			:Int	=0,
			focus		:Float=renderSessionData.camera.focus,
			fz	   	:Float=focus * renderSessionData.camera.zoom,
			vpw			:Float=viewport.width / 2,
			vph			:Float=viewport.height / 2,
			far			:Float=renderSessionData.camera.far,
			fdist		:Float=far - focus,
			vertices	:Array<Dynamic>;
			
		var time:Float=getTimer();
		
		for(var f:Triangle3D in faces){
			
			vertices=f.vertices;
			i=vertices.length;
			
			while(vertex=vertices[--i])
			{
				if(vertex.timestamp==time)
					continue;
				
				vertex.timestamp=time;
				// Center position
				vx=vertex.x;
				vy=vertex.y;
				vz=vertex.z;
				
				s_z=vx * m31 + vy * m32 + vz * m33 + view.n34;
				
				screen=vertex.vertex3DInstance;
				
				if(_useProjectionMatrix)
				{
					s_w=vx * m41 + vy * m42 + vz * m43 + view.n44;
					// to normalized clip space(0.0 to 1.0)
					// NOTE:can skip and simply test(s_z<0)and save a div
					s_z /=s_w;
					
					// is point between near- and far-plane?
					if(screen.visible=(s_z>0 && s_z<1))
					{
						// to normalized clip space(-1,-1)to(1, 1)
						s_x=(vx * m11 + vy * m12 + vz * m13 + view.n14)/ s_w;
						s_y=(vx * m21 + vy * m22 + vz * m23 + view.n24)/ s_w;

						// project to viewport.
						screen.x=s_x * vpw;
						screen.y=s_y * vph;
						
						// NOTE:z not linear, value increases when nearing far-plane.
						screen.z=s_z * s_w;
					}
				}
				else
				{
					if(screen.visible=(focus + s_z>0))
					{
						s_x=vx * m11 + vy * m12 + vz * m13 + view.n14;
						s_y=vx * m21 + vy * m22 + vz * m23 + view.n24;
						
						persp=fz /(focus + s_z);
						screen.x=s_x * persp;
						screen.y=s_y * persp;
						screen.z=s_z;
					}
				}
			}

		}
		
		return 0;
		
		
	}
	
	
	
	/**
	 * Projects vertices.
	 * 
	 * @param	object 					The<code>DisplayObject3D</code>to be projected
	 * @param	renderSessionData		The<code>RenderSessionData</code>holding the containing the camera properties
	 */ 
	public override function projectVertices(vertices:Array, object:DisplayObject3D, renderSessionData:RenderSessionData):Float
	{
			
		var view		:Matrix3D=object.view,
			m11 		:Float=view.n11,
			m12 		:Float=view.n12,
			m13 		:Float=view.n13,
			m21 		:Float=view.n21,
			m22 		:Float=view.n22,
			m23 		:Float=view.n23,
			m31 		:Float=view.n31,
			m32 		:Float=view.n32,
			m33 		:Float=view.n33,
			m41 		:Float=view.n41,
			m42 		:Float=view.n42,
			m43 		:Float=view.n43,
			vx			:Float,
			vy			:Float,
			vz			:Float,
			s_x			:Float,
			s_y			:Float,
			s_z			:Float,
			s_w			:Float,
			vertex		:Vertex3D, 
			screen		:Vertex3DInstance,
			persp 		:Float,
			i			:Int	=vertices.length,
			focus		:Float=renderSessionData.camera.focus,
			fz	   	:Float=focus * renderSessionData.camera.zoom,
			vpw			:Float=viewport.width / 2,
			vph			:Float=viewport.height / 2,
			far			:Float=renderSessionData.camera.far,
			fdist		:Float=far - focus;
		
		while(vertex=vertices[--i])
		{
			// Center position
			vx=vertex.x;
			vy=vertex.y;
			vz=vertex.z;
			
			s_z=vx * m31 + vy * m32 + vz * m33 + view.n34;
			
			screen=vertex.vertex3DInstance;
			
			
			if(_useProjectionMatrix)
			{
				s_w=vx * m41 + vy * m42 + vz * m43 + view.n44;
				// to normalized clip space(0.0 to 1.0)
				// NOTE:can skip and simply test(s_z<0)and save a div
				s_z /=s_w;

				// is point between near- and far-plane?
				if(screen.visible=(s_z>0 && s_z<1))
				{
					// to normalized clip space(-1,-1)to(1, 1)
					s_x=(vx * m11 + vy * m12 + vz * m13 + view.n14)/ s_w;
					s_y=(vx * m21 + vy * m22 + vz * m23 + view.n24)/ s_w;

					// project to viewport.
					screen.x=s_x * vpw;
					screen.y=s_y * vph;

					// NOTE:z not linear, value increases when nearing far-plane.
					screen.z=s_z * s_w;
				}
			}
			else
			{
				if(screen.visible=(focus + s_z>0))
				{
					s_x=vx * m11 + vy * m12 + vz * m13 + view.n14;
					s_y=vx * m21 + vy * m22 + vz * m23 + view.n24;
					
					persp=fz /(focus + s_z);
					screen.x=s_x * persp;
					screen.y=s_y * persp;
					screen.z=s_z;
				}
			}
		}

		return 0;
	}
	
	/**
	 * Updates the Internal camera settings.
	 * 
	 * @param	viewport
	 */ 
	public function update(viewport:Rectangle):Void
	{
		if(!viewport)
			throw new Dynamic("Camera3D#update:Invalid viewport rectangle! " + viewport);

		this.viewport=viewport;

		// used to detect value changes
		_prevFocus=this.focus;
		_prevZoom=this.zoom;
		_prevWidth=this.viewport.width;
		_prevHeight=this.viewport.height;

		if(_prevOrtho !=this.ortho)
		{
			if(this.ortho)
			{
				_prevOrthoProjection=this.useProjectionMatrix;
				this.useProjectionMatrix=true;	
			}
			else
				this.useProjectionMatrix=_prevOrthoProjection;
		}
		
		this.useProjectionMatrix=this._useProjectionMatrix;	
		
		_prevOrtho=this.ortho;
		_prevUseProjection=_useProjectionMatrix;
		
		this.useCulling=_useCulling;
	}
	
	/**
	 * [INTERNAL-USE] Transforms world coordinates Into camera space.
	 * 
	 * @param	transform	An optional transform.
	 */ 
	public override function transformView(transform:Matrix3D=null):Void
	{	
		// check whether camera Internals need updating
		if(	ortho !=_prevOrtho || _prevUseProjection !=_useProjectionMatrix || 
			focus !=_prevFocus || zoom !=_prevZoom || viewport.width !=_prevWidth || viewport.height !=_prevHeight)
		{
			update(viewport);
		}
		
		// handle camera 'types'
		if(_target)
		{
			// Target camera...
			lookAt(_target);
		}
		else if(_transformDirty)
		{
			// Free camera...
			updateTransform();
		}
		
		if(_useProjectionMatrix)
		{
			super.transformView();
			this.eye.calculateMultiply4x4(_projection, this.eye);
		}
		else
		{
			_focusFix.copy(this.transform);
			_focusFix.n14 +=focus * this.transform.n13;
			_focusFix.n24 +=focus * this.transform.n23;
			_focusFix.n34 +=focus * this.transform.n33;
			super.transformView(_focusFix);
		}
		
		// handle frustum if available
		if(Std.is(culler, FrustumCuller))
		{
			// The frustum culler simply uses the camera transform
			FrustumCuller(culler).transform.copy(this.transform);
		}
	}
	
	/**
	 * Whether this camera uses frustum culling.
	 * 
	 * @return Bool
	 */ 
	public override var useCulling(null, set_useCulling):Bool;
 	private function set_useCulling(value:Bool):Void
	{
		super.useCulling=value;
		
		if(_useCulling)
		{
			if(!this.culler)
				this.culler=new FrustumCuller();
				
			FrustumCuller(this.culler).initialize(this.fov, this.viewport.width/this.viewport.height, this.focus/this.zoom, _far);
		}
		else
			this.culler=null;	
	}
	
	/**
	 * Whether this camera uses a projection matrix.
	 */
	public override var useProjectionMatrix(null, set_useProjectionMatrix):Bool;
 	private function set_useProjectionMatrix(value:Bool):Void
	{	
		if(value)
		{
			if(this.ortho)
			{
				var w:Float=viewport.width / 2;
				var h:Float=viewport.height / 2;	
				_projection=createOrthoMatrix(-w, w, -h, h, -_far, _far);	
				_projection=Matrix3D.multiply(_orthoScaleMatrix, _projection);
			}
			else
				_projection=createPerspectiveMatrix(fov, viewport.width/viewport.height, this.focus, this.far);
		}
		else
		{
			if(this.ortho)
				value=true;
		}
		super.useProjectionMatrix=value;
	}
	
	/**
	 * Sets the distance to the far plane.
	 * 
	 * @param	value	The distance to the far plane
	 */ 
	public override var far(null, set_far):Float;
 	private function set_far(value:Float):Void
	{
		if(value>this.focus)
		{
			_far=value;
			this.update(this.viewport);
		}
	}
	
	/**
	 * Sets the distance to the near plane(note that this is simply an alias for #focus).
	 * 
	 * @param	value	The distance to the near plane
	 */  
	public override var near(null, set_near):Float;
 	private function set_near(value:Float):Void
	{
		if(value>0)
		{
			this.focus=value;
			this.update(this.viewport);
		}
	}
	
	/**
	 * Sets the orthographic scale of the camera
	 * 
	 * @param value		The value of the orthographic scale
	 */

	public override var orthoScale(null, set_orthoScale):Float;
 	private function set_orthoScale(value:Float):Void
	{
		super.orthoScale=value;
		this.useProjectionMatrix=this.useProjectionMatrix;
		_prevOrtho=!this.ortho;
		this.update(this.viewport);	
	}
	
	/**
	 * Creates a transformation that produces a parallel projection.
	 * 
	 * @param	left
	 * @param	right
	 * @param	bottom
	 * @param	top
	 * @param	near
	 * @param	far
	 * @return	Matrix3D
	 */
	public static function createOrthoMatrix(left:Float, right:Float, bottom:Float, top:Float, near:Float, far:Float):Matrix3D
	{
		var tx:Float=(right+left)/(right-left);
		var ty:Float=(top+bottom)/(top-bottom);
		var tz:Float=(far+near)/(far-near);
			
		var matrix:Matrix3D=new Matrix3D([
			2/(right-left), 0, 0, tx,
			0, 2/(top-bottom), 0, ty,
			0, 0, -2/(far-near), tz,
			0, 0, 0, 1 
		]);
		
		matrix.calculateMultiply(Matrix3D.scaleMatrix(1,1,-1), matrix);
		
		return matrix;
	}
		
	/**
	 * Creates a transformation that produces a perspective projection.
	 * 
	 * @param	fov
	 * @param	aspect
	 * @param	near
	 * @param	far
	 * @return	Matrix3D
	 */
	public static function createPerspectiveMatrix(fov:Float, aspect:Float, near:Float, far:Float):Matrix3D
	{
		var fov2:Float=(fov/2)*(Math.PI/180);
		var tan:Float=Math.tan(fov2);
		var f:Float=1 / tan;
		
		return new Matrix3D([
			f/aspect, 0, 0, 0,
			0, f, 0, 0,
			0, 0, -((near+far)/(near-far)),(2*far*near)/(near-far),
			0, 0, 1, 0 
		]);
	}
	
	public var projection(get_projection, set_projection):Matrix3D;
 	private function get_projection():Matrix3D { return _projection;}
	
	private var _projection				:Matrix3D;
	private var _prevFocus				:Float;
	private var _prevZoom				:Float;
	private var _prevWidth				:Float;
	private var _prevHeight				:Float;
	private var _prevOrtho				:Bool;
	private var _prevOrthoProjection	:Bool;
	private var _prevUseProjection		:Bool;
	private var _focusFix				:Matrix3D;
}