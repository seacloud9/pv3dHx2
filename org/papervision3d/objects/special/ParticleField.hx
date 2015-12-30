package org.papervision3d.objects.special {
import org.papervision3d.core.geom.Particles;
import org.papervision3d.core.geom.renderables.Particle;
import org.papervision3d.materials.special.ParticleMaterial;	

/**
 * @Author Ralph Hauwert
 */
 
class ParticleField extends Particles
{
	
	private var fieldDepth:Float;
	private var fieldHeight:Float;
	private var fieldWidth:Float;
	private var quantity:Int;		
	private var color:Int;
	
	/**
	* The ParticleField class creates an object with an amount of particles randomly distributed over a specied 3d area.
	* @param	material 	The Material for the to be created particles
	* @param	quantity	The number of particles in the field
	* @param	particleSize	The size of the created particles
	* @param	fieldWidth 	The width of the area
	* @param 	fieldHeight The height of the area
	* @param	fieldDepth	The depth of the area 
	*/
	public function new(mat:ParticleMaterial, quantity:Int=200, particleSize:Float=4, fieldWidth:Float=2000, fieldHeight:Float=2000, fieldDepth:Float=2000)
	{
		super("ParticleField");
		
		this.material=mat;
		this.quantity=quantity;
		
		this.fieldWidth=fieldWidth;
		this.fieldHeight=fieldHeight;
		this.fieldDepth=fieldDepth;
		
		createParticles(particleSize);
	}
	
	private function createParticles(size:Float):Void
	{
		var width2:Float=fieldWidth /2;
		var height2:Float=fieldHeight /2;
		var depth2:Float=fieldDepth /2;
		
		for(i in 0...quantity)
		{
			addParticle(new Particle(material as ParticleMaterial, size,Math.random()* fieldWidth  - width2, Math.random()* fieldHeight - height2, Math.random()* fieldDepth  - depth2));
		}
	}
	
}