package org.papervision3d.events;

import flash.events.Event;

/**
* The AnimationEvent class represents events that are dispatched by the animation engine.
*/
class AnimationEvent extends Event
{
	public static var COMPLETE 		:String="animationComplete";
	public static var ERROR			:String="animationError";
	public static var NEXT_FRAME		:String="animationNextFrame";
	public static var START			:String="animationStart";
	public static var STOP			:String="animationStop";
	public static var PAUSE			:String="animationPause";
	public static var RESUME			:String="animationResume";
	
	public var time:Float;
	public var clip:String;	
	public var data:Dynamic;

	public function new(type:String, time:Float, clip:String="", data:Dynamic=null, bubbles:Bool=false, cancelable:Bool=false)
	{
		super(type, bubbles, cancelable);
		this.time=time;
		this.clip=clip;
		this.data=data;
	}
	
	override public function clone():Event
	{
		return new AnimationEvent(type, time, clip, data, bubbles, cancelable);
	}
}