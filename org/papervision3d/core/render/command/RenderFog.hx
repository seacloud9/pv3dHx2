package org.papervision3d.core.render.command {
import org.papervision3d.core.geom.renderables.AbstractRenderable;
import org.papervision3d.core.render.data.RenderSessionData;
import org.papervision3d.materials.special.FogMaterial;
import org.papervision3d.objects.DisplayObject3D;

import flash.display.Graphics;	

class RenderFog extends RenderableListItem
{

	public var alpha:Float;
	public var material:FogMaterial;
	
	public function new(material:FogMaterial, alpha:Float=0.5, depth:Float=0, do3d:DisplayObject3D=null)
	{
		super();
		this.alpha=alpha;
		this.screenZ=depth;
		this.material=material;
		if(do3d){
			this.renderableInstance=new AbstractRenderable();
			this.renderableInstance.instance=do3d;
		}				
	}
	
	public override function render(renderSessionData:RenderSessionData, graphics:Graphics):Void{
		
		material.draw(renderSessionData, graphics, alpha);
		
	}
	
}