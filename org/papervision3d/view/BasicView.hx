package org.papervision3d.view;

import org.papervision3d.cameras.SpringCamera3D;	
import org.papervision3d.cameras.Camera3D;
import org.papervision3d.cameras.CameraType;
import org.papervision3d.cameras.DebugCamera3D;
import org.papervision3d.core.view.IView;
import org.papervision3d.objects.DisplayObject3D;
import org.papervision3d.render.BasicRenderEngine;
import org.papervision3d.scenes.Scene3D;

/**
 *<p>
 * BasicView provides a simple template for quickly setting up
 * basic Papervision3D projects by creating a viewport, scene,
 * camera, and renderer for you. Because BasicView is a subclass of
 * Sprite, it can be added to any DisplayObject.
 * 
 *</p>
 * 
 *<p>
 *<p>
 * Example:
 *</p>
 *<pre><code>
 * var width:Float=640;
 * var heigth:Float=480;
 * var scaleToStage:Bool=true;
 * var Interactive:Bool=true;
 * var cameraType:String=Camera3D.TYPE;
 * 
 * var myBasicView:BasicView=new BasicView(width, height, scaleToStage, Interactive, cameraType);
 * myDisplayObject.addChild(myBasicView);
 *</code></pre>
 *</p>
 * @author Ralph Hauwert
 */
class BasicView extends AbstractView implements IView
{
	/**
	 * @param viewportWidth		Width of the viewport 
	 * @param viewportHeight	Height of the viewport
	 * @param scaleToStage		Whether you viewport should scale with the stage
	 * @param Interactive		Whether your scene should be Interactive
	 * @param cameraType		A String for the type of camera. @see org.papervision3d.cameras.CameraType
	 * 
	 */	
	public function new(viewportWidth:Float=640, viewportHeight:Float=480, scaleToStage:Bool=true, Interactive:Bool=false, cameraType:String="Target")
	{
		super();
		
		scene=new Scene3D();
		viewport=new Viewport3D(viewportWidth, viewportHeight, scaleToStage, Interactive);
		addChild(viewport);
		renderer=new BasicRenderEngine();
		
		switch(cameraType)
		{
			case CameraType.DEBUG:
				_camera=new DebugCamera3D(viewport);
				break;
			case CameraType.TARGET:
				_camera=new Camera3D(60);
				_camera.target=DisplayObject3D.ZERO;
				break;
			case CameraType.SPRING:
				_camera=new SpringCamera3D();
				_camera.target=DisplayObject3D.ZERO;		
				break;			
			case CameraType.FREE:
			default:
				_camera=new Camera3D(60);
				break;
		}
		
		cameraAsCamera3D.update(viewport.sizeRectangle);
	}
	
	/**
	 * Exposes the camera as a<code>Camera3D</code>
	 */
	public var cameraAsCamera3D(get_cameraAsCamera3D, null):Camera3D;
 	private function get_cameraAsCamera3D():Camera3D
	{
			return _camera as Camera3D;
	}
	
	/**
	 * Exposes the camera as a<code>DebugCamera3D</code>
	 */
	public var cameraAsDebugCamera3D(get_cameraAsDebugCamera3D, null):DebugCamera3D;
 	private function get_cameraAsDebugCamera3D():DebugCamera3D 
	{
			return _camera as DebugCamera3D;
	}
}