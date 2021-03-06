package org.papervision3d.core.material;


/**
 * @Author Ralph Hauwert
 */
 
import flash.display.BitmapData;
import flash.display.Graphics;
import flash.geom.Matrix;

import org.papervision3d.core.proto.MaterialObject3D;
import org.papervision3d.core.render.command.RenderTriangle;
import org.papervision3d.core.render.data.RenderSessionData;
import org.papervision3d.core.render.draw.ITriangleDrawer;

class TriangleMaterial extends MaterialObject3D implements ITriangleDrawer
{
	public function new()
	{
		super();
	}
	
	override public function drawTriangle(tri:RenderTriangle, graphics:Graphics, renderSessionData:RenderSessionData, altBitmap:BitmapData=null, altUV:Matrix=null):Void
	{
		
	}
	
	override public function drawRT(rt:RenderTriangle, graphics:Graphics, renderSessionData:RenderSessionData):Void{
		
	}
	
}