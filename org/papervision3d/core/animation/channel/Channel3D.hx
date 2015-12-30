package org.papervision3d.core.animation.channel {
import org.papervision3d.core.animation.key.CurveKey3D;	
import org.papervision3d.core.animation.curve.Curve3D;	

/**
 * @author Tim Knip / floorplanner.com
 */
class Channel3D 
{
	/** */
	public var startTime:Float;
	
	/** */
	public var endTime:Float;
	
	/**
	 * 
	 */
	public var output:Array<Dynamic>;
	
	/**
	 * 
	 */
	private var _curves:Array<Dynamic>;
	
	/**
	 * 
	 */
	public function new()
	{
		this.output=new Array();
		
		_curves=new Array();
	}
	
	/**
	 * Adds a curve.
	 * 
	 * @param curve	The curve to add.
	 * 
	 * @return	The added curve or null on failure.
	 * 
	 * @see org.papervision3d.core.animation.curve.Curve3D
	 */
	public function addCurve(curve:Curve3D, updatesTimes:Bool=true):Curve3D
	{
		if(_curves.indexOf(curve)==-1)
		{
			_curves.push(curve);
			this.output.push(0.0);
			if(updatesTimes)
			{
				updateStartAndEndTime();
			}
			return curve;
		}
		return null;
	}
	
	/**
	 * 
	 */
	public function clone():Channel3D
	{
		var channel:Channel3D=new Channel3D();
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
	 * Removes a curve.
	 * 
	 * @param curve	The curve to remove.
	 * 
	 * @return	The remove curve or null on failure.
	 * 
	 * @see org.papervision3d.core.animation.curve.Curve3D
	 */
	public function removeCurve(curve:Curve3D):Curve3D
	{
		var pos:Int=_curves.indexOf(curve);
		if(pos>=0)
		{
			_curves.splice(pos, 1);
			this.output.splice(pos, 1);
			updateStartAndEndTime();
			return curve;
		}
		return null;
	}
	
	/**
	 * 
	 */
	public function update(time:Float):Void
	{
		var curves:Array<Dynamic>=_curves;
		var num:Int=curves.length;
		var curve:Curve3D;
		var i:Int=0;
		
		for(i=0;i<num;i++)
		{
			curve=curves[i];
			output[i]=curve.evaluate(time);
		}
	}
	
	private function updateStartAndEndTime():Void
	{
		var curve:Curve3D;
		
		if(_curves.length==0)
		{
			startTime=endTime=0;
			return;
		}
		
		startTime=Number.MAX_VALUE;
		endTime=-startTime;
	
		for(curve in _curves)
		{
			if(!curve.keys || curve.keys.length<1)
			{
				continue;
			}
			var startKey:CurveKey3D=curve.keys[0];
			var endKey:CurveKey3D=curve.keys[curve.keys.length-1];
			
			startTime=Math.min(startTime, startKey.input);
			endTime=Math.max(endTime, endKey.input);
		}
	}
}