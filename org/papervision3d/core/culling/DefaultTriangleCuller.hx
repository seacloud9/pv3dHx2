package org.papervision3d.core.culling {
import org.papervision3d.core.geom.renderables.Triangle3D;
import org.papervision3d.core.geom.renderables.Vertex3DInstance;
import org.papervision3d.core.proto.MaterialObject3D;
import org.papervision3d.objects.DisplayObject3D;	

class DefaultTriangleCuller implements ITriangleCuller
{
	
	protected static var x0:Float;
	protected static var y0:Float;
	protected static var x1:Float;
	protected static var y1:Float;
	protected static var x2:Float;
	protected static var y2:Float;
	
	public function new()
	{
		
	}

	public function testFace(face:Triangle3D, vertex0:Vertex3DInstance, vertex1:Vertex3DInstance, vertex2:Vertex3DInstance):Bool
	{
		//Material checks & backface culling
		if(vertex0.visible && vertex1.visible && vertex2.visible){
			
			var material:MaterialObject3D=face.material ? face.material:face.instance.material;
			if(material.invisible){
				return false;
			};
			x0=vertex0.x;
			y0=vertex0.y;
			x1=vertex1.x;
			y1=vertex1.y;
			x2=vertex2.x;
			y2=vertex2.y;
			
			if(material.oneSide){
				if(material.opposite){
					if((x2 - x0)*(y1 - y0)-(y2 - y0)*(x1 - x0)>0)
					{
						return false;
					}
				}else{
					if((x2 - x0)*(y1 - y0)-(y2 - y0)*(x1 - x0)<0)
					{
						return false;
					}
				}
			}
			return true;
		}
		return false;
	}
	
}