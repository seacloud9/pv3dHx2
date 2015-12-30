package org.papervision3d.view;

import flash.display.Sprite;
import flash.events.Event;

import org.papervision3d.core.proto.CameraObject3D;
import org.papervision3d.core.view.IView;
import org.papervision3d.render.BasicRenderEngine;
import org.papervision3d.scenes.Scene3D;

/**
 * @Author Ralph Hauwert
 */
class AbstractView extends Sprite implements IView
{
	private var _camera:CameraObject3D;
	private var _height:Float;
	private var _width:Float;
	
	public var scene:Scene3D;
	public var viewport:Viewport3D;
	public var renderer:BasicRenderEngine;
	
	public function new()
	{
		super();
	}
	
	public function startRendering():Void
	{
		addEventListener(Event.ENTER_FRAME, onRenderTick);
		viewport.containerSprite.cacheAsBitmap=false;
	}
	
	public function stopRendering(reRender:Bool=false, cacheAsBitmap:Bool=false):Void
	{
		removeEventListener(Event.ENTER_FRAME, onRenderTick);
		if(reRender){
			onRenderTick();	
		}
		if(cacheAsBitmap){
			viewport.containerSprite.cacheAsBitmap=true;
		}else{
			viewport.containerSprite.cacheAsBitmap=false;
		}
	}
	
	public function singleRender():Void
	{
		onRenderTick();
	}
	
	private function onRenderTick(event:Event=null):Void
	{
		renderer.renderScene(scene, _camera, viewport);
	}
	
	public var camera(get_camera, set_camera):CameraObject3D;
 	private function get_camera():CameraObject3D
	{
		return _camera;
	}
	
	private function set_viewportWidth(width:Float):Void
	{
		_width=width;
		viewport.width=width;
	}
	
	public var viewportWidth(get_viewportWidth, set_viewportWidth):Float;
 	private function get_viewportWidth():Float
	{
		return _width;
	}
	
	private function set_viewportHeight(height:Float):Void
	{
		_height=height;
		viewport.height=height;
	}
	
	public var viewportHeight(get_viewportHeight, set_viewportHeight):Float;
 	private function get_viewportHeight():Float
	{
		return _height;
	}
	
}