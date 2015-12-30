package org.papervision3d.core.effects.view {
import org.papervision3d.cameras.Camera3D;
import org.papervision3d.core.math.Matrix3D;
import org.papervision3d.core.proto.CameraObject3D;
import org.papervision3d.view.BasicView;
import org.papervision3d.view.Viewport3D;

import flash.events.Event;
import flash.geom.ColorTransform;	

class ReflectionView extends BasicView
{
	
	public var viewportReflection:Viewport3D;
	public var cameraReflection:CameraObject3D;
	public var surfaceHeight:Float=0;
	
	//public var reflectionMatrix:Matrix3D;// for future use... 
	
	private var _autoScaleToStage:Bool;
	
	public function new(viewportWidth:Float=640, viewportHeight:Float=320, scaleToStage:Bool=true, Interactive:Bool=false, cameraType:String="Target")
	{
		super(viewportWidth, viewportHeight, scaleToStage, Interactive, cameraType);
		
		//set up reflection viewport and camera
		viewportReflection=new Viewport3D(viewportWidth, viewportHeight,scaleToStage, false);

		// For future use... 
		//reflectionMatrix=new Matrix3D();
		//createReflectionMatrix(null);
		
		
		
		// add the reflection viewport to the stage 
		addChild(viewportReflection);
		setChildIndex(viewportReflection,0);
		
		// flip it
		viewportReflection.scaleY=-1;

		// and move it down
		viewportReflection.y=viewportHeight;

		cameraReflection=new Camera3D();
		
		

		// SAVING THIS CODE FOR LATER(may require transparent reflections...)
		/*var matrix:Array<Dynamic>=new Array();
		matrix=matrix.concat([0.4, 0, 0, 0, 0]);// red
		matrix=matrix.concat([0, 0.4, 0, 0, 0]);// green
		matrix=matrix.concat([0, 0, 0.4, 0, 0]);// blue
		matrix=matrix.concat([0, 0, 0, 1, 0]);// alpha
		viewportReflection.filters=[new ColorMatrixFilter(matrix),new BlurFilter(8,8,1)];
		*/
		
		addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
		
		this.autoScaleToStage=scaleToStage;
		
		setReflectionColor(0.5,0.5,0.5);
	}
	
	public override function singleRender():Void
	{
		
		cameraReflection.zoom=camera.zoom;
		cameraReflection.focus=camera.focus;
		if(Std.is(camera, Camera3D))
		{
			Camera3D(cameraReflection).useCulling=Camera3D(camera).useCulling;
		
		}
		if(camera.target)camera.lookAt(camera.target);
		cameraReflection.transform.copy(camera.transform);
		
		// reflection matrix! Doesn't work yet - turns planes inside out:-S
		//cameraReflection.transform.calculateMultiply(cameraReflection.transform, reflectionMatrix);
		
		cameraReflection.y=-camera.y;
		cameraReflection.rotationX=-camera.rotationX;
		cameraReflection.rotationY=camera.rotationY;
		cameraReflection.rotationZ=-camera.rotationZ;
		
		cameraReflection.y+=surfaceHeight;
		
		
		
		renderer.renderScene(scene, cameraReflection, viewportReflection);			
		super.singleRender();
	
	}
	
	
	public function setReflectionColor(redMultiplier:Float=0, greenMultiplier:Float=0, blueMultiplier:Float=0, redOffset:Float=0, greenOffset:Float=0, blueOffset:Float=0):Void
	{
		viewportReflection.transform.colorTransform=new ColorTransform(redMultiplier, greenMultiplier, blueMultiplier, 1, redOffset, greenOffset, blueOffset);
		
	}


	/* For future use... 

	public function createReflectionMatrix(plane:Plane3D):Void
	{
		var a:Float=0;//plane.normal.x;
		var b:Float=1;//plane.normal.y;
		var c:Float=0;//plane.normal.z;
		
		
		reflectionMatrix.n11=1-(2*a*a);
		reflectionMatrix.n12=0-(2*a*b);
		reflectionMatrix.n13=0-(2*a*c);
		
		reflectionMatrix.n21=0-(2*a*b);
		reflectionMatrix.n22=1-(2*b*b);
		reflectionMatrix.n23=0-(2*b*c);
		
		reflectionMatrix.n31=0-(2*a*c);
		reflectionMatrix.n32=0-(2*b*c);
		reflectionMatrix.n33=1-(2*c*c);
	}
	
	*/

	/**
	 * We need  to move the reflection view whenever the stage is resized so we have to implement
	 * the same functionality as the Viewport3D, ie we add a stage resize listener(once we're on the stage). 
	 */
	 
	 
	public var autoScaleToStage(null, set_autoScaleToStage):Bool;
 	private function set_autoScaleToStage(scale:Bool):Void
	{
		_autoScaleToStage=scale;
		if(scale && stage !=null)
		{
			onStageResize();
		}
		
	}
	
	/**
	 * Triggered when added to the stage to start listening to stage resizing
	 */
	private function onAddedToStage(event:Event):Void
	{
		stage.addEventListener(Event.RESIZE, onStageResize);
		onStageResize();
	}

	/**
	 * Triggered when removed from the stage to remove the stage resizing listener
	 */
	private function onRemovedFromStage(event:Event):Void
	{
		stage.removeEventListener(Event.RESIZE, onStageResize);
	}
	
	// all we need to do is move the view down
	private function onStageResize(e:Event=null):Void
	{
		viewportReflection.y=stage.stageHeight;
		
	}
			
			
}