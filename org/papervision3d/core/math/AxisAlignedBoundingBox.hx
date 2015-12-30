package org.papervision3d.core.math;

import org.papervision3d.core.geom.renderables.Vertex3D;

class AxisAlignedBoundingBox
{
	public var minX:Float;
	public var minY:Float;
	public var minZ:Float;
	public var maxX:Float;
	public var maxY:Float;
	public var maxZ:Float;
	
	private var _vertices:Array<Dynamic>;
	
	/**
	 * @author Ralph Hauwert/Alex Clarke
	 */
	public function new(minX:Float, minY:Float, minZ:Float, maxX:Float, maxY:Float, maxZ:Float)
	{
		this.minX=minX;
		this.minY=minY;
		this.minZ=minZ;
		this.maxX=maxX;
		this.maxY=maxY;
		this.maxZ=maxZ;
		createBoxVertices();
	}
	
	private function createBoxVertices():Void
	{
		_vertices=new Array();
		_vertices.push(new Vertex3D(minX, minY, minZ));
		_vertices.push(new Vertex3D(minX, minY, maxZ));
		_vertices.push(new Vertex3D(minX, maxY, minZ));
		_vertices.push(new Vertex3D(minX, maxY, maxZ));
		_vertices.push(new Vertex3D(maxX, minY, minZ));
		_vertices.push(new Vertex3D(maxX, minY, maxZ));
		_vertices.push(new Vertex3D(maxX, maxY, minZ));
		_vertices.push(new Vertex3D(maxX, maxY, maxZ));
	}
	
	public function getBoxVertices():Array
	{
		return _vertices;
	}
	
	public function merge(bbox:AxisAlignedBoundingBox):Void
	{
		this.minX=Math.min(this.minX, bbox.minX);
		this.minY=Math.min(this.minY, bbox.minY);
		this.minZ=Math.min(this.minZ, bbox.minZ);
		this.maxX=Math.max(this.maxX, bbox.maxX);
		this.maxY=Math.max(this.maxY, bbox.maxY);
		this.maxZ=Math.max(this.maxZ, bbox.maxZ);	
		createBoxVertices();
	}
	
	public static function createFromVertices(vertices:Array):AxisAlignedBoundingBox
	{
		var minX:Float=Number.MAX_VALUE;
		var minY:Float=Number.MAX_VALUE;
		var minZ:Float=Number.MAX_VALUE;
		var maxX:Float=-minX;
		var maxY:Float=-minY;
		var maxZ:Float=-minZ;
		var v	:Vertex3D;
		
		for(v in vertices)
		{
			minX=Math.min(minX, v.x);
			minY=Math.min(minY, v.y);
			minZ=Math.min(minZ, v.z);
			maxX=Math.max(maxX, v.x);
			maxY=Math.max(maxY, v.y);
			maxZ=Math.max(maxZ, v.z);
		}
		
		return new AxisAlignedBoundingBox(minX, minY, minZ, maxX, maxY, maxZ);
	}

}