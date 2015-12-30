package org.papervision3d.core.render.data;

/**
 * @Author Ralph Hauwert
 */
 
import org.papervision3d.core.geom.renderables.IRenderable;
import org.papervision3d.core.proto.MaterialObject3D;
import org.papervision3d.objects.DisplayObject3D;

class RenderHitData
{
	public var startTime:Int=0;
	public var endTime:Int=0;
	public var hasHit:Bool=false;
	
	public var displayObject3D:DisplayObject3D;
	public var material:MaterialObject3D;
	
	public var renderable:IRenderable;
	
	public var u:Float;
	public var v:Float;
	
	public var x:Float;
	public var y:Float;
	public var z:Float;
	
	public function new():Void
	{
		
	}
	
	public function toString():String
	{
		return displayObject3D +" "+renderable;
	}
	
	public function clear():Void
	{
		startTime=0;
		endTime=0;
		hasHit=false;
		displayObject3D=null;
		material=null;
		renderable=null;
		u=0;
		v=0;
		x=0;
		y=0;
		z=0;
	}
	
	public function clone():RenderHitData
	{
		var rhd:RenderHitData=new RenderHitData();
		
		rhd.startTime=startTime;
		rhd.endTime=endTime;
		rhd.hasHit=hasHit;
		rhd.displayObject3D=displayObject3D;
		rhd.material=material;
		rhd.renderable=renderable;
		rhd.u=u;
		rhd.v=v;
		rhd.x=x;
		rhd.y=y;
		rhd.z=z;
		
		return rhd;
	}
}