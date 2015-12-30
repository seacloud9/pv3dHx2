package org.papervision3d.core.animation.key 
{
/**
 * @author Tim Knip / floorplanner.com
 */
class CurveKey3D 
{
	/**
	 * 
	 */
	public var input:Float;
	
	/**
	 * 
	 */
	public var output:Float;
	
	/**
	 * Constructor.
	 */
	public function new(input:Float=0, output:Float=0)
	{
		this.input=input;
		this.output=output;
	}
	
	/**
	 * Clone.
	 * 
	 * @return The cloned key.
	 */
	public function clone():CurveKey3D
	{
		return new CurveKey3D(this.input, this.output);
	}
}