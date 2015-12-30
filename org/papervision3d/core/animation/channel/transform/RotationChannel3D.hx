package org.papervision3d.core.animation.channel.transform {
import org.papervision3d.core.animation.curve.Curve3D;	
import org.papervision3d.core.animation.channel.Channel3D;	
import org.papervision3d.core.math.Matrix3D;	
import org.papervision3d.core.math.Number3D;	

/**
 * @author Tim Knip / floorplanner.com
 */
class RotationChannel3D extends TransformChannel3D 
{
	public var axis:Float3D;
	
	public function new(axis:Float3D)
	{
		super(null);
	
		this.axis=axis;
	}

	/**
	 * 
	 */
	override public function clone():Channel3D 
	{
		var channel:RotationChannel3D=new RotationChannel3D(this.axis.clone());
		var curve:Curve3D;
		var i:Int;
		
		for(i=0;i<_curves.length;i++)
		{
			curve=_curves[i];
			channel.addCurve(curve.clone(),(i==_curves.length-1));
		}
		return channel;
	}
	
	override public function update(time:Float):Void 
	{
		if(!_curves || !_curves.length)
		{
			return;
		}
		
		super.update(time);

		transform=Matrix3D.rotationMatrix(axis.x, axis.y, axis.z, output[0], transform);
	}
}