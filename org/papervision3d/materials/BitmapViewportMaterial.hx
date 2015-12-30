package org.papervision3d.materials;

import org.papervision3d.core.render.draw.ITriangleDrawer;
import org.papervision3d.view.BitmapViewport3D;

class BitmapViewportMaterial extends BitmapMaterial implements ITriangleDrawer
{
	public function new(bitmapViewport:BitmapViewport3D, precise:Bool=false)
	{
		super(bitmapViewport.bitmapData, precise);
	}
	
}