package org.papervision3d.core.render;

import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;

import org.papervision3d.core.proto.CameraObject3D;
import org.papervision3d.core.proto.SceneObject3D;
import org.papervision3d.core.render.command.IRenderListItem;
import org.papervision3d.core.render.command.RenderableListItem;
import org.papervision3d.core.render.data.RenderStatistics;
import org.papervision3d.view.Viewport3D;

class AbstractRenderEngine extends EventDispatcher implements IRenderEngine
{
	public function new(target:IEventDispatcher=null)
	{
		super(target);
	}
	
	public function renderScene(scene:SceneObject3D, camera:CameraObject3D, viewPort:Viewport3D):RenderStatistics
	{
		return null;
	}
	
	public function addToRenderList(renderCommand:RenderableListItem):Int
	{
		return 0;
	}
	
	public function removeFromRenderList(renderCommand:IRenderListItem):Int
	{
		return 0;
	}
	
}