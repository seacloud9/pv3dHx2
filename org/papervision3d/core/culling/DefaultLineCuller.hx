package org.papervision3d.core.culling {	import org.papervision3d.core.geom.renderables.Line3D;		import org.papervision3d.core.culling.ILineCuller;

/**	 * @author Seb Lee-Delisle	 */	class DefaultLineCuller implements ILineCuller 	{				public function new()		{					}				public function testLine(line:Line3D):Bool 		{			// culls if one of the points is behind the camera... 			return((line.v0.vertex3DInstance.visible)&&(line.v1.vertex3DInstance.visible));
	}
}