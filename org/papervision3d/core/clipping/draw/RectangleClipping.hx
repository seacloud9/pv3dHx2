package org.papervision3d.core.clipping.draw;


import org.papervision3d.core.render.command.RenderableListItem;

/** Rectangle clipping */
class RectangleClipping extends Clipping
{
	public function new(minX:Float=-1000000, minY:Float=-1000000, maxX:Float=1000000, maxY:Float=1000000)
	{
		this.minX=minX;
		this.maxX=maxX;
		this.minY=minY;
		this.maxY=maxY;
	}
	
	/**
	 * @inheritDoc
	 */
	public override function asRectangleClipping():RectangleClipping
	{
		return this;
	}
	
	/**
	 * @inheritDoc
	 */
	public override function check(pri:RenderableListItem):Bool
	{
		if(pri.maxX<minX)
			return false;
		if(pri.minX>maxX)
			return false;
		if(pri.maxY<minY)
			return false;
		if(pri.minY>maxY)
			return false;

		return true;
	}
	
	/**
	 * @inheritDoc
	 */
	public override function rect(minX:Float, minY:Float, maxX:Float, maxY:Float):Bool
	{
		if(this.maxX<minX)
			return false;
		if(this.minX>maxX)
			return false;
		if(this.maxY<minY)
			return false;
		if(this.minY>maxY)
			return false;

		return true;
	}
	
	/**
	 * Used to trace the values of a rectangle clipping object.
	 * 
	 * @return A string representation of the rectangle clipping object.
	 */
	public function toString():String
	{
		return "{minX:" + minX + " maxX:" + maxX + " minY:" + minY + " maxY:" + maxY + "}";
	}
}