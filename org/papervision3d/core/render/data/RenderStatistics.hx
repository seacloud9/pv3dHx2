package org.papervision3d.core.render.data;


/**
 * @Author Ralph Hauwert
 */
 
class RenderStatistics
{
	public var projectionTime:Int=0;
	public var renderTime:Int=0;
	public var rendered:Int=0;
	public var triangles:Int=0;
	public var culledTriangles:Int=0;
	public var particles:Int=0;
	public var culledParticles:Int=0;
	public var lines:Int=0;
	public var shadedTriangles:Int=0;
	public var filteredObjects:Int=0;
	public var culledObjects:Int=0;
	
	public function new()
	{
		
	}
	
	public function clear():Void
	{
		projectionTime=0;
		renderTime=0;
		rendered=0;
		particles=0;
		triangles=0;
		culledTriangles=0;
		culledParticles=0;
		lines=0;
		shadedTriangles=0;
		filteredObjects=0;
		culledObjects=0;
	}
	
	public function clone():RenderStatistics
	{
		var rs:RenderStatistics=new RenderStatistics();
		rs.projectionTime=projectionTime;
		rs.renderTime=renderTime;
		rs.rendered=rendered;
		rs.particles=particles;
		rs.triangles=triangles;
		rs.culledTriangles=culledTriangles;
		rs.lines=lines;
		rs.shadedTriangles=shadedTriangles;
		rs.filteredObjects=filteredObjects;
		rs.culledObjects=culledObjects;
		return rs;
	}
	
	public function toString():String
	{
		return new Std.string("ProjectionTime:"+projectionTime+" RenderTime:"+renderTime+" Particles:"+particles+" CulledParticles:"+culledParticles+" Triangles:"+triangles+" ShadedTriangles:"+shadedTriangles+" CulledTriangles:"+culledTriangles+" FilteredObjects:"+filteredObjects+" CulledObjects:"+culledObjects+"");
	}
	
}