package org.papervision3d.lights;

import org.papervision3d.core.math.Number3D;
import org.papervision3d.core.proto.LightObject3D;

class PointLight3D extends LightObject3D
{
	public static var DEFAULT_POS:Float3D=new Float3D(0, 0, -1000);
	
	/**
	 * Constructor.
	 * 
	 * @param	showLight	A Bool value indicating whether the light is visible.
	 * @param	flipped		A Bool value indicating whether to flip the light-direction(needed for correct DAE-shading).
	 */
	public function new(showLight:Bool=false, flipped:Bool=false)
	{
		super(showLight, flipped);
		x=DEFAULT_POS.x;
		y=DEFAULT_POS.y;
		z=DEFAULT_POS.z;
	}

}