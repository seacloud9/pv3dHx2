package org.papervision3d.core.animation.clip 
{

/**
 * @author Tim Knip / floorplanner.com
 */
class AnimationClip3D 
{
	/**
	 * 
	 */
	public var name:String;
	
	/**
	 * 
	 */
	public var startTime:Float;
	
	/**
	 * 
	 */
	public var endTime:Float;
	
	/**
	 * 
	 */
	public function new(name:String, startTime:Float=0.0, endTime:Float=0.0)
	{
		this.name=name;
		this.startTime=startTime;
		this.endTime=endTime;	
	}
	
	/**
	 * Clone.
	 * 
	 * @return
	 */
	public function clone():AnimationClip3D
	{
		return new AnimationClip3D(this.name, this.startTime, this.endTime);
	}
 	}