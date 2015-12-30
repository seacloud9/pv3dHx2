package org.papervision3d.materials.shadematerials;

import flash.display.BitmapData;
import flash.display.Graphics;
import flash.geom.Matrix;

import org.papervision3d.core.geom.renderables.Triangle3D;
import org.papervision3d.core.geom.renderables.Vertex3DInstance;
import org.papervision3d.core.material.AbstractSmoothShadeMaterial;
import org.papervision3d.core.math.Matrix3D;
import org.papervision3d.core.proto.LightObject3D;
import org.papervision3d.core.render.command.RenderTriangle;
import org.papervision3d.core.render.data.RenderSessionData;
import org.papervision3d.core.render.draw.ITriangleDrawer;

/**
 * @Author Ralph Hauwert
 */
class EnvMapMaterial extends AbstractSmoothShadeMaterial implements ITriangleDrawer
{
	private static var p0:Float;
	private static var q0:Float;
	private static var p1:Float;
	private static var q1:Float;		
	private static var p2:Float;
	private static var q2:Float;
	private static var v0:Vertex3DInstance;
	private static var v1:Vertex3DInstance;
	private static var v2:Vertex3DInstance;
	private static var x1:Float;
	private static var x0:Float;
	private static var x2:Float;
	private static var y0:Float;
	private static var y1:Float;
	private static var y2:Float;
	
	
	private var lightmapHalfheight:Float;
	private var lightmapHalfwidth:Float;
	public var _lightMap:BitmapData;
	public var backenvmap:BitmapData;
	
	public function new(light:LightObject3D, lightMap:BitmapData, backEnvMap:BitmapData=null, ambientColor:Int=0)
	{
		super();
		this.light=light;
		this.lightMap=lightMap;
		if(!backenvmap){
			this.backenvmap=new BitmapData(1,1,false, ambientColor);
		}else{
			this.backenvmap=backenvmap;
		}
	}
	
	/**
	 * Localized stuff.
	 */
	private static var useMap:BitmapData;
	override public function drawTriangle(tri:RenderTriangle, graphics:Graphics, renderSessionData:RenderSessionData, altBitmap:BitmapData=null, altUV:Matrix=null):Void
	{
		var face3D:Triangle3D=tri.triangle;
		lightMatrix=Matrix3D(lightMatrices[face3D.instance]);
		
		
		/*
		v0=triangle.v0.vertex3DInstance;
		v1=triangle.v1.vertex3DInstance;
		v2=triangle.v2.vertex3DInstance;
		triangle.v0.normal.copyTo(v0.normal);
		triangle.v1.normal.copyTo(v1.normal);
		triangle.v2.normal.copyTo(v2.normal);
		Matrix3D.multiplyVector3x3(lm, v0.normal);
		Matrix3D.multiplyVector3x3(lm, v1.normal);
		Matrix3D.multiplyVector3x3(lm, v2.normal);
		*/
		
		p0=lightmapHalfwidth*(face3D.v0.normal.x * lightMatrix.n11 + face3D.v0.normal.y * lightMatrix.n12 + face3D.v0.normal.z * lightMatrix.n13)+lightmapHalfwidth;
		q0=lightmapHalfheight*(face3D.v0.normal.x * lightMatrix.n21 + face3D.v0.normal.y * lightMatrix.n22 + face3D.v0.normal.z * lightMatrix.n23)+lightmapHalfheight;
		p1=lightmapHalfwidth*(face3D.v1.normal.x * lightMatrix.n11 + face3D.v1.normal.y * lightMatrix.n12 + face3D.v1.normal.z * lightMatrix.n13)+lightmapHalfwidth;
		q1=lightmapHalfheight*(face3D.v1.normal.x * lightMatrix.n21 + face3D.v1.normal.y * lightMatrix.n22 + face3D.v1.normal.z * lightMatrix.n23)+lightmapHalfheight;
		p2=lightmapHalfwidth*(face3D.v2.normal.x * lightMatrix.n11 + face3D.v2.normal.y * lightMatrix.n12 + face3D.v2.normal.z * lightMatrix.n13)+lightmapHalfwidth;
		q2=lightmapHalfheight*(face3D.v2.normal.x * lightMatrix.n21 + face3D.v2.normal.y * lightMatrix.n22 + face3D.v2.normal.z * lightMatrix.n23)+lightmapHalfheight;
			
		x0=tri.v0.x;
		y0=tri.v0.y;
		x1=tri.v1.x;
		y1=tri.v1.y;
		x2=tri.v2.x;
		y2=tri.v2.y;

		triMatrix.a=x1 - x0;
		triMatrix.b=y1 - y0;
		triMatrix.c=x2 - x0;
		triMatrix.d=y2 - y0;
		triMatrix.tx=x0;
		triMatrix.ty=y0;
				
		transformMatrix.tx=p0;
		transformMatrix.ty=q0;
		transformMatrix.a=p1 - p0;
		transformMatrix.b=q1 - q0;
		transformMatrix.c=p2 - p0;
		transformMatrix.d=q2 - q0;
		transformMatrix.invert();
		transformMatrix.concat(triMatrix);
		
		if(face3D.faceNormal.x * lightMatrix.n31 + face3D.faceNormal.y * lightMatrix.n32 + face3D.faceNormal.z * lightMatrix.n33>0){
			useMap=_lightMap;
		}else{
			useMap=backenvmap;
		}
		graphics.beginBitmapFill(useMap, transformMatrix, false, false);
		graphics.moveTo(x0, y0);
		graphics.lineTo(x1, y1);
		graphics.lineTo(x2, y2);
		graphics.lineTo(x0, y0);
		graphics.endFill();
		renderSessionData.renderStatistics.shadedTriangles++;
	}
	
	private function set_lightMap(lightMap:BitmapData):Void
	{
		_lightMap=lightMap;
		lightmapHalfwidth=lightMap.width/2;
		lightmapHalfheight=lightMap.height/2;
	}
	
	public var lightMap(get_lightMap, set_lightMap):BitmapData;
 	private function get_lightMap():BitmapData
	{
		return _lightMap;
	}
	
}