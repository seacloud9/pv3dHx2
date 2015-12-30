package org.papervision3d.core.geom;

/**
 * @Author Andy Zupko
 */

import org.papervision3d.core.geom.renderables.Pixel3D;
import org.papervision3d.core.render.command.RenderPixels;
import org.papervision3d.core.render.data.RenderSessionData;
import org.papervision3d.objects.DisplayObject3D;
import org.papervision3d.view.layer.BitmapEffectLayer;

class Pixels extends Vertices3D
{
	
	private var vertices:Array<Dynamic>;
	private var renderCommand:RenderPixels;
	public var pixels:Array<Dynamic>;
	public var layer:BitmapEffectLayer;
	public var screenDepth:Int;
	public var sort:Bool;

	/**
	 * Vertexpixels
	 * 
	 * A simple Particle Renderer for Papervision3D.
	 * 
	 * Renders added pixels to a given container using Flash's drawing API.
	 */
	public function new(effectLayer:BitmapEffectLayer, name:String="pixels3d")
	{
		this.layer=effectLayer;
		this.vertices=new Array();
		this.pixels=new Array();
		super(vertices, name);
		this.screenDepth=0;
		this.sort=false;
		this.renderCommand=new RenderPixels(this);
	}
	
	/**
	 * Project
	 */
	public override function project(parent:DisplayObject3D, renderSessionData:RenderSessionData):Float
	{
		super.project(parent,renderSessionData);		
		
		if(this.sort){
			
			pixels.sort(sortOnDepth);
		}
		
		renderSessionData.renderer.addToRenderList(this.renderCommand);
		return 1;
	}
	
	
	
	/**
	 * addParticle(particle);
	 * 
	 * @param	particle	partical to be added and rendered by to this Vertexpixels Dynamic.
	 */
	public function addPixel3D(pixel:Pixel3D):Void
	{
		pixel.instance=this;
		pixels.push(pixel);
		vertices.push(pixel.vertex3D);
	}
	
	/**
	 * removeParticle(pixel);
	 * 
	 * @param	pixel	partical to be removed from this Vertexpixels Dynamic.
	 */
	public function removePixel3D(pixel:Pixel3D):Void
	{
		pixel.instance=null;
		pixels.splice(pixels.indexOf(pixel),1);
		vertices.splice(vertices.indexOf(pixel.vertex3D),1);
	}

	
	/**
	 * removeAllpixels()
	 * 
	 * removes all pixels in this Vertexpixels Dynamic.
	 */
	public function removeAllpixels():Void
	{
		pixels=new Array();
		vertices=new Array();
		geometry.vertices=vertices;
	}
	
	private function sortOnDepth(a:Pixel3D, b:Pixel3D):Float {
	   		
		if(a.vertex3D.vertex3DInstance.z>b.vertex3D.vertex3DInstance.z){
			return 1;
		} else if(a.vertex3D.vertex3DInstance.z<b.vertex3D.vertex3DInstance.z){
			return -1;
		} else  {
			return 0;
		}
	}
	
	
	
}