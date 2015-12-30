package org.papervision3d.core.animation.channel.geometry 
{
import org.papervision3d.core.geom.renderables.Vertex3D;	
import org.papervision3d.core.proto.GeometryObject3D;	

/**
 * The VerticesChannel3D animates the GeometryObject3D#vertices array.
 * 
 * @see org.papervision3d.core.proto.GeometryObject3D
 * @see org.papervision3d.core.geom.renderables.Vertex3D
 * 
 * @author Tim Knip / floorplanner.com
 */
class VerticesChannel3D extends GeometryChannel3D 
{
	/**
	 * 
	 */
	public function new(geometry:GeometryObject3D)
	{
		super(geometry);
	}
	
	/**
	 * 
	 */
	override public function update(time:Float):Void 
	{
		var curves:Array<Dynamic>=_curves;
		var numCurves:Int=curves.length;
		
		if(!_geometry || !_geometry.vertices ||(_geometry.vertices.length * 3)!=numCurves)
		{
			return;
		}
		
		var verts:Array<Dynamic>=_geometry.vertices;
		var numVerts:Int=verts.length;
		var v:Vertex3D;
		var i:Int, j:Int=0;
		
		super.update(time);
		
		for(i=0;i<numVerts;i++)
		{
			v=verts[i];
			
			v.x=output[j];
			v.y=output[j+1];
			v.z=output[j+2];
			
			j +=3;
		}
	}
}