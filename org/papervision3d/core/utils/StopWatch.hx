package org.papervision3d.core.utils;

import flash.events.EventDispatcher;
import flash.utils.getTimer;

/**
 * StopWatch times how long certain actions(e.g., a render)take
 */
class StopWatch extends EventDispatcher
{
	private var startTime:Int;
	private var stopTime:Int;
	private var elapsedTime:Int;
	private var isRunning:Bool;
	
	public function new()
	{
		super();
	}
	
	/**
	 * Starts the timer
	 */
	public function start():Void
	{
		if(!isRunning){
			startTime=getTimer();
			isRunning=true;
		}
	}
	
	/**
	 * Stops the timer
	 */
	public function stop():Int
	{
		if(isRunning){
			stopTime=getTimer();
			elapsedTime=stopTime-startTime;
			isRunning=false;
			return elapsedTime;
		}else{
			return 0;
		}
	}
	
	/**
	 * Resets the timer
	 */
	public function reset():Void
	{
		isRunning=false;
	}

}