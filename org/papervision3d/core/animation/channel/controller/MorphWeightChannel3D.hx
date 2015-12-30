package org.papervision3d.core.animation.channel.controller 
{
import org.papervision3d.core.animation.channel.Channel3D;	
import org.papervision3d.core.controller.MorphController;

/**
 * This channel targets the weights of a MorphController.
 * 
 * @see org.papervision3d.core.controller.MorphController
 * @see org.papervision3d.core.animation.channel.Channel3D
 * 
 * @author Tim Knip / floorplanner.com
 */
class MorphWeightChannel3D extends Channel3D 
{
	
	/** */
	public var controller:MorphController;
	
	/** */
	public var morphTarget:Int;
	
	/**
	 * 
	 */
	public function new(controller:MorphController, morphTarget:Int)
	{
		super();
		
		this.controller=controller;
		this.morphTarget=morphTarget;
	}

	/**
	 * Update the channel.
	 * 
	 * @param time	Time in seconds.
	 */
	override public function update(time:Float):Void 
	{
		if(!_curves || !controller)
		{
			return;
		}
		
		var numCurves:Int=_curves.length;
		
		if(numCurves==1)
		{
			super.update(time);
			controller.weights[morphTarget]=output[0];
		}
	}
}