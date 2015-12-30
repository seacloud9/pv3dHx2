package org.papervision3d.materials.shadematerials;

import flash.display.BitmapData;
import flash.display.Graphics;
import flash.geom.Matrix;

import org.papervision3d.core.geom.renderables.Triangle3D;
import org.papervision3d.core.material.AbstractLightShadeMaterial;
import org.papervision3d.core.math.Matrix3D;
import org.papervision3d.core.proto.LightObject3D;
import org.papervision3d.core.render.command.RenderTriangle;
import org.papervision3d.core.render.data.RenderSessionData;
import org.papervision3d.core.render.draw.ITriangleDrawer;
import org.papervision3d.materials.utils.LightMaps;

/**
 *	@Author Ralph Hauwert
 */
class FlatShadeMaterial extends AbstractLightShadeMaterial implements ITriangleDrawer
{
	private static var currentColor:Int;
	private static var zAngle:Int;
	
	private var _colors:Array<Dynamic>;
	
	public function new(light:LightObject3D, lightColor:Int=0xffffff, ambientColor:Int=0x000000, specularLevel:Int=0)
	{
		super();
		this.fillAlpha=1;
		this.light=light;
		_colors=LightMaps.getFlatMapArray(lightColor,ambientColor,specularLevel);
	}
	
	/**
	 * Localized stuff.
	 */
	private static var zd:Float;
	private static var x0:Float;
	private static var y0:Float;
	override public function drawTriangle(tri:RenderTriangle, graphics:Graphics, renderSessionData:RenderSessionData, altBitmap:BitmapData=null, altUV:Matrix=null):Void
	{
		var face3D:Triangle3D=tri.triangle;
		lightMatrix=Matrix3D(lightMatrices[face3D.instance]);
		zd=face3D.faceNormal.x * lightMatrix.n31 + face3D.faceNormal.y * lightMatrix.n32 + face3D.faceNormal.z * lightMatrix.n33;
		
		if(zd<0){
			if(doubleSided==false){
				zd=0;
			}else{
				zd=Math.abs(zd);
			}
			
		};
		
		x0=tri.v0.x;
		y0=tri.v0.y;
		zAngle=zd*0xff;
		currentColor=_colors[zAngle];
		
		graphics.beginFill(currentColor,fillAlpha);
		graphics.moveTo(x0, y0);
		graphics.lineTo(tri.v1.x, tri.v1.y);
		graphics.lineTo(tri.v2.x, tri.v2.y);
		graphics.lineTo(x0, y0);
		graphics.endFill();
		renderSessionData.renderStatistics.shadedTriangles++;
	}
	
}