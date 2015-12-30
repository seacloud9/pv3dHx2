package org.papervision3d.materials.shadematerials;

import flash.display.BitmapData;
import flash.display.Graphics;
import flash.geom.Matrix;

import org.papervision3d.core.geom.renderables.Triangle3D;
import org.papervision3d.core.material.AbstractSmoothShadeMaterial;
import org.papervision3d.core.math.Matrix3D;
import org.papervision3d.core.proto.LightObject3D;
import org.papervision3d.core.render.command.RenderTriangle;
import org.papervision3d.core.render.data.RenderSessionData;
import org.papervision3d.core.render.draw.ITriangleDrawer;
import org.papervision3d.core.render.material.IUpdateBeforeMaterial;
import org.papervision3d.materials.utils.LightMaps;

/**
 * @Author Ralph Hauwert
 */
class GouraudMaterial extends AbstractSmoothShadeMaterial implements ITriangleDrawer, IUpdateBeforeMaterial
{
	
	private var gouraudMap:BitmapData;
	
	public function new(light:LightObject3D, lightColor:Int=0xFFFFFF, ambientColor:Int=0x000000, specularLevel:Int=0)
	{
		super();
		this.light=light;
		gouraudMap=LightMaps.getGouraudMaterialMap(lightColor, ambientColor, specularLevel);
	}
	
	override public function drawTriangle(tri:RenderTriangle, graphics:Graphics, renderSessionData:RenderSessionData, altBitmap:BitmapData=null, altUV:Matrix=null):Void
	{
		var face3D:Triangle3D=tri.triangle;
		lightMatrix=Matrix3D(lightMatrices[face3D.instance]);
	
		var p0:Float=(face3D.v0.normal.x * lightMatrix.n31 + face3D.v0.normal.y * lightMatrix.n32 + face3D.v0.normal.z * lightMatrix.n33)+1;
		var p1:Float=(face3D.v1.normal.x * lightMatrix.n31 + face3D.v1.normal.y * lightMatrix.n32 + face3D.v1.normal.z * lightMatrix.n33)+1;
		var p2:Float=(face3D.v2.normal.x * lightMatrix.n31 + face3D.v2.normal.y * lightMatrix.n32 + face3D.v2.normal.z * lightMatrix.n33)+1;


		p0 *=127;
		p1 *=127;
		p2 *=127;


		transformMatrix.tx=p0;
		transformMatrix.ty=1;
		transformMatrix.a=p1 - p0;
		transformMatrix.c=p2 - p0;
		transformMatrix.b=2;
		transformMatrix.d=3;
		transformMatrix.invert();
		
		var x0:Float=tri.v0.x;
		var y0:Float=tri.v0.y;
		var x1:Float=tri.v1.x;
		var y1:Float=tri.v1.y;
		var x2:Float=tri.v2.x;
		var y2:Float=tri.v2.y;

		triMatrix.a=x1 - x0;
		triMatrix.b=y1 - y0;
		triMatrix.c=x2 - x0;
		triMatrix.d=y2 - y0;
		triMatrix.tx=x0;
		triMatrix.ty=y0;
		transformMatrix.concat(triMatrix);
		
		graphics.beginBitmapFill(gouraudMap, transformMatrix, true, false);
		graphics.moveTo(x0, y0);
		graphics.lineTo(x1, y1);
		graphics.lineTo(x2, y2);
		graphics.lineTo(x0, y0);
		graphics.endFill();
		
		renderSessionData.renderStatistics.shadedTriangles++;
	}
	
}