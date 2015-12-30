package org.papervision3d.materials.special;

import flash.display.BitmapData;
import flash.display.Graphics;
import flash.geom.Matrix;

import org.papervision3d.core.geom.renderables.Triangle3D;
import org.papervision3d.core.material.TriangleMaterial;
import org.papervision3d.core.proto.MaterialObject3D;
import org.papervision3d.core.render.command.RenderTriangle;
import org.papervision3d.core.render.data.RenderSessionData;
import org.papervision3d.core.render.draw.ITriangleDrawer;
import org.papervision3d.objects.DisplayObject3D;

class CompositeMaterial extends TriangleMaterial implements ITriangleDrawer
{	
	public var materials:Array<Dynamic>;
	
	public function new()
	{
		init();
	}
	
	private function init():Void
	{
		materials=new Array();
	}
	
	public function addMaterial(material:MaterialObject3D):Void
	{
		materials.push(material);
		for(object in objects){
			var do3d:DisplayObject3D=cast(object, DisplayObject3D);
			material.registerObject(do3d);
		}
	}
	
	public function removeMaterial(material:MaterialObject3D):Void
	{
		materials.splice(materials.indexOf(material),1);
	}
	
	public function removeAllMaterials():Void
	{
		materials=new Array();
	}
	
	override public function registerObject(displayObject3D:DisplayObject3D):Void
	{
		super.registerObject(displayObject3D);
		for(var material:MaterialObject3D in materials){
			material.registerObject(displayObject3D);
		}
	}
	
	override public function unregisterObject(displayObject3D:DisplayObject3D):Void
	{
		super.unregisterObject(displayObject3D);
		for(var material:MaterialObject3D in materials){
			material.unregisterObject(displayObject3D);
		}
	}
	
	override public function drawTriangle(tri:RenderTriangle, graphics:Graphics, renderSessionData:RenderSessionData, altBitmap:BitmapData=null, altUV:Matrix=null):Void{
		for(var n:MaterialObject3D in materials){
			if(!n.invisible){
				n.drawTriangle(tri, graphics, renderSessionData);
			}
		}
	}
	
}