package org.papervision3d.core.culling {
import org.papervision3d.core.geom.renderables.Triangle3D;
import org.papervision3d.core.geom.renderables.Vertex3DInstance;	

class CompositeTriangleCuller implements ITriangleCuller
{
	
	private var cullers:Array<Dynamic>;
	
	public function new()
	{
		init();
	}
	
	private function init():Void
	{
		cullers=new Array();
	}
	
	public function addCuller(culler:ITriangleCuller):Void
	{
		cullers.push(culler);
	}
	
	public function removeCuller(culler:ITriangleCuller):Void
	{
		cullers.splice(cullers.indexOf(culler),1);
	}
	
	public function clearCullers():Void
	{
		cullers=new Array();
	}
	
	public function testFace(face3D:Triangle3D, vertex0:Vertex3DInstance, vertex1:Vertex3DInstance, vertex2:Vertex3DInstance):Bool
	{
		for(var culler:ITriangleCuller in cullers)
		{
			//Add "modes here". Like inclusive or exclusive	
		}
		return true;
	}
	
}