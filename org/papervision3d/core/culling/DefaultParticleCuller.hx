package org.papervision3d.core.culling;

import org.papervision3d.core.geom.renderables.Particle;

class DefaultParticleCuller implements IParticleCuller
{
	
	public function new()
	{
		
	}
	
	public function testParticle(particle:Particle):Bool
	{
		if(particle.material.invisible==false){
			if(particle.vertex3D.vertex3DInstance.visible==true){
				return true;
			}
		}
		return false;
	}
	
}