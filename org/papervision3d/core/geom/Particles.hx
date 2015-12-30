package org.papervision3d.core.geom;

import org.papervision3d.core.geom.renderables.Vertex3DInstance;	
import org.papervision3d.core.geom.renderables.Vertex3D;	

import flash.geom.Rectangle;	

import org.papervision3d.core.math.Matrix3D;	
import org.papervision3d.core.geom.renderables.Particle;
import org.papervision3d.core.render.data.RenderSessionData;
import org.papervision3d.objects.DisplayObject3D;
import org.papervision3d.core.culling.IObjectCuller;	

/**
 *<p>
 * The Particles object is a DisplayObject3D that is used solely for displaying particle objects.
 * A single particle is a 2D graphic that is scaled and positioned relative to a 3D point, without
 * any perspective distortion. In effect, it's like a plane that is always facing the camera. This 
 * is sometimes referred to as a 3D sprite, pointsprite or billboard.
 * 
 * A particle's appearance is defined by its ParticleMaterial. 
 * 
 *</p>
 * 
 *<p>
 * Example:
 *</p>
 *<pre><code>
 * 
 *  //This example creates a Particles DisplayObject3D and adds 100 particles Into it. 
 * 
 *	var numParticles:Int=100;
 *	
 *	var particles:Particles=new Particles();
 *	var particleMaterial:ParticleMaterial=new ParticleMaterial(0xff0000, 0.8,ParticleMaterial.SHAPE_CIRCLE);
 *	var particleSize:Float=5;
 *	
 *	for(i in 0...numParticles)
 *	{
 * 		var xpos:Float=Math.random()*200;
 * 		var ypos:Float=Math.random()*200;
 * 		var zpos:Float=Math.random()*200;
 * 
 *		var particle:Particle=new Particle(particleMaterial, particleSize, xpos, ypos, zpos);
 *		particles.addParticle(particle);
 *		
 *	}
 *	scene.addChild(particles);
 * 
 	 *</code></pre>
 *</p>
 * 
 *<p>
 * See also:ParticleMaterial, MovieAssetParticleMaterial, MovieParticleMaterial, BitmapParticleMaterial. 
 *</p>
 * 
 * @Author Ralph Hauwert
 * @Author Seb Lee-Delisle
 */
	class Particles extends Vertices3D
{
	
	private var vertices:Array<Dynamic>;
	public var particles:Array<Dynamic>;
	private static var _newID:Int=0;
	
	 /**
	 * @param name				An identifier for this Particles object. 
	 * 
	 */
	 	
	public function new(name:String="Particles")
	{
		name=name + _newID++;
		this.vertices=new Array();
		this.particles=new Array();
		
		super(vertices, name);
	}
	
	/**
	* Converts 3D vertices Into 2D space, to prepare for rendering onto the stage.
	*
	* @param 	parent				The parent DisplayObject3D
	* @param 	renderSessionData	The renderSessionData object for this render cycle. 
	 * 
	*/

	public override function project(parent:DisplayObject3D, renderSessionData:RenderSessionData):Float
	{
		super.project(parent,renderSessionData);
		
		var viewport:Rectangle=renderSessionData.camera.viewport;
		// TODO(MEDIUM)implement Frustum camera rendering for Particles
		
			//return projectFrustum(parent, renderSessionData);
		if(this.culled)return 0;

		var p:Particle;
		
		
	
		for(p in particles)
		{
			if(renderSessionData.camera is IObjectCuller)
			{
				var v:Vertex3D=p.vertex3D;
				p.renderScale=viewport.width /2 /(v.x * view.n41 + v.y * view.n42 + v.z * view.n43 + view.n44);
			} 
			else
			{	
				var fz:Float=(renderSessionData.camera.focus*renderSessionData.camera.zoom);
				
				//TODO:Shouldn't this be p.renderScale=fz /(fz + p.vertex3D.vertex3DInstance.z);? 
				p.renderScale=fz /(renderSessionData.camera.focus + p.vertex3D.vertex3DInstance.z);
			}
			p.updateRenderRect();
			
			if(renderSessionData.viewPort.particleCuller.testParticle(p)){
				p.renderCommand.screenZ=p.vertex3D.vertex3DInstance.z;
				renderSessionData.renderer.addToRenderList(p.renderCommand);	
			}else{
				renderSessionData.renderStatistics.culledParticles++;
			}
		}
		return 1;
	}
	
	/*
	public override function projectFrustum(parent:DisplayObject3D, renderSessionData:RenderSessionData):Float 
	{
		
	
		var view:Matrix3D=this.view,
			viewport:Rectangle=renderSessionData.camera.viewport,
			m11:Float=view.n11,
			m12:Float=view.n12,
			m13:Float=view.n13,
			m21:Float=view.n21,
			m22:Float=view.n22,
			m23:Float=view.n23,
			m31:Float=view.n31,
			m32:Float=view.n32,
			m33:Float=view.n33,
			m41:Float=view.n41,
			m42:Float=view.n42,
			m43:Float=view.n43,
			vx	:Float,
			vy	:Float,
			vz	:Float,
			s_x	:Float,
			s_y	:Float,
			s_z	:Float,
			s_w:Float,
			vpw:Float=viewport.width / 2,
			vph:Float=viewport.height / 2,
			vertex:Vertex3D, 
			screen:Vertex3DInstance,
			vertices:Array<Dynamic>=this.geometry.vertices,
			i		:Int	=particles.length,
			p		:Particle;
			
		while(p=particles[--i])
		{
			vertex=p.vertex3D;
			
			// Center position
			vx=vertex.x;
			vy=vertex.y;
			vz=vertex.z;
			
			s_z=vx * m31 + vy * m32 + vz * m33 + view.n34;
			s_w=vx * m41 + vy * m42 + vz * m43 + view.n44;
			
			//trace(s_w);
			
			screen=vertex.vertex3DInstance;
			
			// to normalized clip space(0.0 to 1.0)
			// NOTE:can skip and simply test(s_z<0)and save a div
			s_z /=s_w;
		
			// is point between near- and far-plane?
			if(screen.visible=(s_z>0 && s_z<1))
			{
				// to normalized clip space(-1,-1)to(1, 1)
				s_x=(vx * m11 + vy * m12 + vz * m13 + view.n14)/ s_w;
				s_y=(vx * m21 + vy * m22 + vz * m23 + view.n24)/ s_w;
				
				// NOTE:optionally we can flag screen verts here 
				//screen.visible=(s_x>-1 && s_x<1 && s_y>-1 && s_y<1);
				
				// project to viewport.
				screen.x=s_x * vpw;
				
				screen.y=s_y * vph;
				
				//Papervision3D.logger.debug("sx:" + screen.x + " " +screen.y);
				// NOTE:z not lineair, value increases when nearing far-plane.
				screen.z=s_z*s_w;
			} 
				trace("particles projectfrustum vertex  visible:", screen.visible);
			
		}
		
		return 0;
	}
	
	*/
	
	/**
	 * Adds a particle. 
	 * 
	 * @param	particle	The particle to be added.
	 */
	public function addParticle(particle:Particle):Void
	{
		particle.instance=this;
		particles.push(particle);
		vertices.push(particle.vertex3D);
	}
	
	/**
	 * Removes a particle. 
	 * 
	 * @param	particle	The particle to be removed.
	 */
	public function removeParticle(particle:Particle):Void
	{
		particle.instance=null;
		particles.splice(particles.indexOf(particle,0), 1);
		vertices.splice(vertices.indexOf(particle.vertex3D,0), 1);
	}
	
	/**
	 * Removes all the particles. 
	 *  
	 */
	public function removeAllParticles():Void
	{
		particles=new Array();
		vertices=new Array();
		geometry.vertices=vertices;
	}
	
	
}