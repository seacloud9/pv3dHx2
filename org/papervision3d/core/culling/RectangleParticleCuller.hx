package org.papervision3d.core.culling {

import org.papervision3d.core.geom.renderables.Particle;
import org.papervision3d.core.geom.renderables.Vertex3DInstance;
import org.papervision3d.core.geom.renderables.Vertex3D;	
import flash.geom.Rectangle;
import flash.geom.Point;
import org.papervision3d.core.math.util.FastRectangleTools;	


class RectangleParticleCuller implements IParticleCuller
{
	private static var vInstance:Vertex3DInstance;
	private static var testPoint:Point;
	
	public var cullingRectangle:Rectangle;
	
	public function new(cullingRectangle:Rectangle=null)
	{
		this.cullingRectangle=cullingRectangle;
		testPoint=new Point();
	}
	
	public function testParticle(particle:Particle):Bool
	{
		vInstance=particle.vertex3D.vertex3DInstance;
		
		if(particle.material.invisible==false){
			if(vInstance.visible)
			{
				if(FastRectangleTools.intersects(particle.renderRect, cullingRectangle))
				{
					return true;
				}
			}
		}
		return false;
	}
	
	
	
}