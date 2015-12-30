package org.papervision3d.events;

import flash.events.Event;

import org.papervision3d.core.render.data.RenderSessionData;

class RendererEvent extends Event
{
	public static inline var RENDER_DONE:String="renderDone";
	public static inline var PROJECTION_DONE:String="projectionDone";
	
	public var renderSessionData:RenderSessionData;
	
	public function new(type:String, renderSessionData:RenderSessionData)
	{
		super(type);
		this.renderSessionData=renderSessionData;
	}
	
	public function clear():Void
	{
		renderSessionData=null;
	}
	
	override public function clone():Event
	{
		return new RendererEvent(type, renderSessionData);
	}
	
}