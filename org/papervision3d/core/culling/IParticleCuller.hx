package org.papervision3d.core.culling;

import org.papervision3d.core.geom.renderables.Particle;

interface IParticleCuller
{
	function testParticle(particle:Particle):Bool;
}