package org.papervision3d.materials.special;

import flash.display.Graphics;

import org.papervision3d.core.render.data.RenderSessionData;
import org.papervision3d.view.Viewport3D;

class FogMaterial
{
	public var color:Int;
	public var alpha:Float;
	
	public function new(color:Int=0)
	{
		this.color=color;	
	}
	
	public function draw(renderSessionData:RenderSessionData, graphics:Graphics, alpha:Float):Void{
		var vp:Viewport3D=renderSessionData.viewPort;
		graphics.beginFill(color, alpha);
		graphics.drawRect(-(vp.width)*0.5, -(vp.height)*0.5, vp.width, vp.height);
		graphics.endFill();
	}

}