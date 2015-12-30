package org.papervision3d.view.stats;

import flash.display.MovieClip;
import flash.events.Event;
import flash.utils.getTimer;

import org.papervision3d.core.render.AbstractRenderEngine;
import org.papervision3d.core.render.data.RenderSessionData;
import org.papervision3d.events.RendererEvent;

class AbstractStatsView extends MovieClip
{
	private var _renderEngine:AbstractRenderEngine;
	private var _renderSessionData:RenderSessionData;
	private var _fps:Int;
	private var lastFrameTime:Int;
	private var currentFrameTime:Int;
	
	public function new()
	{
		super();
		setupListeners();
	}
	
	private function setupListeners():Void
	{
		addEventListener(Event.ENTER_FRAME, onFrame);
	}
	
	private function onRenderDone(event:RendererEvent):Void
	{
		renderSessionData=event.renderSessionData;
	}
	
	private function onFrame(event:Event):Void
	{
		currentFrameTime=getTimer();
		fps=1000/(currentFrameTime - lastFrameTime);
		lastFrameTime=currentFrameTime;
	}
	
	private function set_renderEngine(renderEngine:AbstractRenderEngine):Void
	{
		if(_renderEngine){
			_renderEngine.removeEventListener(RendererEvent.RENDER_DONE, onRenderDone);
		}
		if(renderEngine !=null){
			renderEngine.addEventListener(RendererEvent.RENDER_DONE, onRenderDone);
		}
		_renderEngine=renderEngine;
	}
	
	public var renderEngine(get_renderEngine, set_renderEngine):AbstractRenderEngine;
 	private function get_renderEngine():AbstractRenderEngine
	{
		return _renderEngine;	
	}
	
	private function set_renderSessionData(renderSessionData:RenderSessionData):Void
	{
		_renderSessionData=renderSessionData;	
	}
	
	public var renderSessionData(get_renderSessionData, set_renderSessionData):RenderSessionData;
 	private function get_renderSessionData():RenderSessionData
	{
		return _renderSessionData;
	}
	
	private function set_fps(fps:Int):Void
	{
		_fps=fps;	
	}
	
	public var fps(get_fps, set_fps):Int;
 	private function get_fps():Int
	{
		return _fps;
	}
}