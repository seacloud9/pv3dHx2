package org.papervision3d.core.animation.channel.transform 
{
import org.papervision3d.core.animation.curve.Curve3D;	
import org.papervision3d.core.animation.channel.Channel3D;	
import org.papervision3d.core.math.Matrix3D;	
import org.papervision3d.core.animation.channel.transform.TransformChannel3D;

/**
 * @author Tim Knip / floorplanner.com
 */
class MatrixChannel3D extends TransformChannel3D 
{
	/**
	 * Constructor.
	 * 
	 * @param transform
	 */
	public function new(transform:Matrix3D)
	{
		super(transform);
	}
	
	/**
	 * 
	 */
	override public function clone():Channel3D 
	{
		var channel:MatrixChannel3D=new MatrixChannel3D(this.transform);
		var curve:Curve3D;
		var i:Int;
		
		for(i=0;i<_curves.length;i++)
		{
			curve=_curves[i];
			channel.addCurve(curve.clone(),(i==_curves.length-1));
		}
		return channel;
	}
	
	/**
	 * 
	 */
	override public function update(time:Float):Void 
	{
		super.update(time);
		
		var i:Int;
		var m:Matrix3D=this.transform;
		var curves:Array<Dynamic>=_curves;
		var numCurves:Int=curves.length;
		var props:Array<Dynamic>=[
			"n11", "n12", "n13", "n14",
			"n21", "n22", "n23", "n24",
			"n31", "n32", "n33", "n34",
			"n41", "n42", "n43", "n44"
		];
		
		if(curves && numCurves>11)
		{
			for(i=0;i<numCurves;i++)
			{
				m[ props[i] ]=output[i];
			}
		}
	}
}