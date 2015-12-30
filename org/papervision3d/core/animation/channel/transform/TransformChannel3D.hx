package org.papervision3d.core.animation.channel.transform {
import org.papervision3d.core.animation.curve.Curve3D;	
import org.papervision3d.core.math.Matrix3D;	
import org.papervision3d.core.animation.channel.Channel3D;

/**
 * @author Tim Knip / floorplanner.com
 	 */
class TransformChannel3D extends Channel3D 
{
	public var transform:Matrix3D;

	public function new(transform:Matrix3D)
	{
		super();
		
		this.transform=transform || Matrix3D.IDENTITY;
	}

	override public function clone():Channel3D 
	{
		var channel:TransformChannel3D=new TransformChannel3D(this.transform);
		var curve:Curve3D;
		var i:Int;
		
		for(i=0;i<_curves.length;i++)
		{
			curve=_curves[i];
			channel.addCurve(curve.clone(),(i==_curves.length-1));
		}
		return channel;
	}
}