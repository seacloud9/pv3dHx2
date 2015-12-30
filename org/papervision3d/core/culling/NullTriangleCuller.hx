package org.papervision3d.core.culling;

import org.papervision3d.core.geom.renderables.Vertex3DInstance;
import org.papervision3d.core.geom.renderables.Triangle3D;

class NullTriangleCuller implements ITriangleCuller
{
	public function new()
	{
	}

	public function testFace(face3D:Triangle3D, vertex0:Vertex3DInstance, vertex1:Vertex3DInstance, vertex2:Vertex3DInstance):Bool
	{
		return true;
	}
	
}