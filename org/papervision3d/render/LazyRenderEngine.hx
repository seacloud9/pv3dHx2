package org.papervision3d.render {
import org.papervision3d.core.proto.CameraObject3D;
import org.papervision3d.core.render.IRenderEngine;
import org.papervision3d.core.render.data.RenderStatistics;
import org.papervision3d.scenes.Scene3D;
import org.papervision3d.view.Viewport3D;	

/**
 * @Author Ralph Hauwert
 */
class LazyRenderEngine extends BasicRenderEngine implements IRenderEngine
{
	
	private var _camera:CameraObject3D;
	private var _scene:Scene3D;
	private var _viewport:Viewport3D;
	
	public function new(scene:Scene3D, camera:CameraObject3D, viewport:Viewport3D)
	{
		super();
		this.scene=scene;
		this.camera=camera;
		this.viewport=viewport;
	}
	
	public function render():RenderStatistics
	{
		return renderScene(scene,camera,viewport);	
	}
	
	private function set_camera(camera:CameraObject3D):Void
	{
		_camera=camera;
	}
	
	public var camera(get_camera, set_camera):CameraObject3D;
 	private function get_camera():CameraObject3D
	{
		return _camera;	
	}
	
	private function set_scene(scene:Scene3D):Void
	{
		_scene=scene;		
	}
	
	public var scene(get_scene, set_scene):Scene3D;
 	private function get_scene():Scene3D
	{
		return _scene;
	}
	
	private function set_viewport(viewport:Viewport3D):Void
	{
		_viewport=viewport;
	}
	
	public var viewport(get_viewport, set_viewport):Viewport3D;
 	private function get_viewport():Viewport3D
	{
		return _viewport;
	}

}