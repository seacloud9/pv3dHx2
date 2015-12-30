package org.papervision3d.core.animation;

interface IAnimatable
{
	/**
	 * Pauses the animation.
	 */ 
	function pause():Void;
	
	/**
	 * Plays the animation.
	 * 
	 * @param 	clip	Clip to play. Default is "all"
	 * @param 	loop	Whether the animation should loop. Default is true.
	 */ 
	function play(clip:String="all", loop:Bool=true):Void;
	
	/**
	 * Resumes a paused animation.
	 * 
	 * @param loop 	Whether the animation should loop. Defaults is true.
	 */ 
	function resume(loop:Bool=true):Void;
	
	/**
	 * Stops the animation.
	 */ 
	function stop():Void;
	
	/**
	 * Whether the animation is playing. This property is read-only.
	 */
	function get playing():Bool;
}