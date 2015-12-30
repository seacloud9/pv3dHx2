package org.papervision3d.core.geom.renderables;



import flash.geom.Matrix;
import flash.geom.Rectangle;

import org.papervision3d.core.render.command.IRenderListItem;
import org.papervision3d.core.render.command.RenderParticle;
import org.papervision3d.materials.special.ParticleMaterial;	 

/**
 * This is the single renderable Particle object, used by Particles.as
 * 
 * See Particles.as for a full explanation. 
 * 
 * 
 * @author Ralph Hauwert
 * @author Seb Lee-Delisle
 */


class Particle extends AbstractRenderable implements IRenderable
{
	/**
	 * The size or scale factor of the particle.  
	 */		
	public var size:Float;
	public var vertex3D:Vertex3D;
	public var material:ParticleMaterial;
	public var renderCommand:RenderParticle;
	public var renderScale:Float;
	public var drawMatrix:Matrix;
	public var rotationZ:Float=0;
	
	/**
	 * The rectangle containing the particles visible area in 2D.  
	 */		
	public var renderRect:Rectangle;
	
	/**
	 * 
	 * @param material		The ParticleMaterial used for rendering the Particle
	 * @param size			The size of the particle. For some materials(ie BitmapParticleMaterial)this is used as a scale factor. 
	 * @param x				x position of the particle
	 * @param y				y position of the particle
	 * @param z				z position of the particle
	 * 
	 */		
	public function new(material:ParticleMaterial, size:Float=1, x:Float=0, y:Float=0, z:Float=0)
	{
		this.material=material;
		this.size=size;
		this.renderCommand=new RenderParticle(this);
		this.renderRect=new Rectangle();
		vertex3D=new Vertex3D(x,y,z);
		drawMatrix=new Matrix();
	}
	
	/**
	 * This is called during the projection cycle. It updates the rectangular area that 
	 * the particle is drawn Into. It's important for the culling phase, and changes dependent
	 * on the type of material used.  
	 *  
	 */		

	public function updateRenderRect():Void
	{
		material.updateRenderRect(this);
	}
	
	public var x(null, set_x):Float;
 	private function set_x(x:Float):Void
	{
		vertex3D.x=x;
	}
	
	public function get x():Float
	{
		return vertex3D.x;
	}
	
	public var y(null, set_y):Float;
 	private function set_y(y:Float):Void
	{
		vertex3D.y=y;
	}
	
	public function get y():Float
	{
		return vertex3D.y;
	}
	
	public var z(null, set_z):Float;
 	private function set_z(z:Float):Void
	{
		vertex3D.z=z;
	}
	
	public function get z():Float
	{
		return vertex3D.z;
	}
	
	override public function getRenderListItem():IRenderListItem
	{
		return renderCommand;
	}
	
}