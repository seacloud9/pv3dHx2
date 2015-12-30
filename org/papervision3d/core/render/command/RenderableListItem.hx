package org.papervision3d.core.render.command;


/**
 * @Author Ralph Hauwert
 */	
import flash.geom.Point;

import org.papervision3d.core.geom.renderables.AbstractRenderable;
import org.papervision3d.core.render.data.QuadTreeNode;
import org.papervision3d.core.render.data.RenderHitData;
import org.papervision3d.objects.DisplayObject3D;

class RenderableListItem extends AbstractRenderListItem
{
	public var renderable:Class;
	public var renderableInstance:AbstractRenderable;
	public var instance:DisplayObject3D;
	
	public var area:Float;
	
	public var minX:Float;
	
	/**
	 * Indicates the maximum x value of the drawing primitive.
	 */
	public var maxX:Float;
	
	/**
	 * Indicates the minimum y value of the drawing primitive.
	 */
	public var minY:Float;
	
	/**
	 * Indicates the maximum y value of the drawing primitive.
	 */
	public var maxY:Float;
	
	public var minZ:Float;
	public var maxZ:Float;
	
	 public function getZ(x:Float, y:Float, focus:Float):Float
	{
		return screenZ;
	}
			
	/**
	 * Reference to the last quadrant used by the drawing primitive. Used in<code>QuadTree</code>
	 */
	public var quadrant:QuadTreeNode;
	
	public function new()
	{
		super();
	}
	
	public function hitTestPoint2D(point:Point, renderHitData:RenderHitData):RenderHitData
	{
		return renderHitData;
	}
	
	public function update():Void{
		
		
	
	}
	
	 public function quarter(focus:Float):Array{
	 	return []
	 }
	
}