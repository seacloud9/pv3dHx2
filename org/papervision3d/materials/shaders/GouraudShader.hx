package org.papervision3d.materials.shaders {
import flash.display.BitmapData;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.geom.Matrix;
import flash.geom.Rectangle;

import org.papervision3d.core.geom.renderables.Triangle3D;
import org.papervision3d.core.geom.renderables.Vertex3DInstance;
import org.papervision3d.core.math.Matrix3D;
import org.papervision3d.core.math.Number3D;
import org.papervision3d.core.proto.LightObject3D;
import org.papervision3d.core.render.data.RenderSessionData;
import org.papervision3d.core.render.shader.ShaderObjectData;
import org.papervision3d.materials.utils.LightMaps;	

/**
 * @Author Ralph Hauwert
 */
class GouraudShader extends LightShader
{
	private var _ambientColor:Int;
	private var gouraudMap:BitmapData;
	
	private static var triMatrix:Matrix=new Matrix();
	private static var transformMatrix:Matrix=new Matrix();
	private static var light:Float3D;
	private static var p0:Float;
	private static var q0:Float;
	private static var p1:Float;
	private static var q1:Float;		
	private static var p2:Float;
	private static var q2:Float;
	private static var v0:Vertex3DInstance;
	private static var v1:Vertex3DInstance;
	private static var v2:Vertex3DInstance;
	private static var currentGraphics:Graphics;
	
	public function new(light:LightObject3D, lightColor:Int=0xFFFFFF, ambientColor:Int=0x000000, specularLevel:Int=0)
	{
		super();
		this.light=light;
		gouraudMap=LightMaps.getGouraudMap(lightColor, ambientColor, specularLevel);
	}
	
	/**
	 * Localized vars
	 */
	private var lightMatrix:Matrix3D;
	override public function renderLayer(triangle:Triangle3D, renderSessionData:RenderSessionData, sod:ShaderObjectData):Void
	{
		lightMatrix=Matrix3D(sod.lightMatrices[this]);
		p0=(triangle.v0.normal.x * lightMatrix.n31 + triangle.v0.normal.y * lightMatrix.n32 + triangle.v0.normal.z * lightMatrix.n33)*255;
		transformMatrix.tx=p0;
		transformMatrix.ty=1;
		transformMatrix.a=((triangle.v1.normal.x * lightMatrix.n31 + triangle.v1.normal.y * lightMatrix.n32 + triangle.v1.normal.z * lightMatrix.n33)*255)- p0;
		transformMatrix.c=((triangle.v2.normal.x * lightMatrix.n31 + triangle.v2.normal.y * lightMatrix.n32 + triangle.v2.normal.z * lightMatrix.n33)*255)- p0;
		transformMatrix.b=2;
		transformMatrix.d=3;
		transformMatrix.invert();
		triMatrix=sod.uvMatrices[triangle] ? sod.uvMatrices[triangle]:sod.getUVMatrixForTriangle(triangle);
		transformMatrix.concat(triMatrix);
		
		currentGraphics=Sprite(layers[sod.object]).graphics;
		currentGraphics.beginBitmapFill(gouraudMap, transformMatrix,false,false);
		currentGraphics.moveTo(triMatrix.tx, triMatrix.ty);
		currentGraphics.lineTo(triMatrix.a+triMatrix.tx, triMatrix.b+triMatrix.ty);
		currentGraphics.lineTo(triMatrix.c+triMatrix.tx, triMatrix.d+triMatrix.ty);
		currentGraphics.lineTo(triMatrix.tx, triMatrix.ty);
		currentGraphics.endFill();
	}
	
	private static var ts:Sprite=new Sprite();
	override public function renderTri(triangle:Triangle3D, renderSessionData:RenderSessionData, sod:ShaderObjectData,bmp:BitmapData):Void
	{
		lightMatrix=Matrix3D(sod.lightMatrices[this]);
		p0=(triangle.v0.normal.x * lightMatrix.n31 + triangle.v0.normal.y * lightMatrix.n32 + triangle.v0.normal.z * lightMatrix.n33)*255;
		transformMatrix.tx=p0;
		transformMatrix.ty=1;
		transformMatrix.a=((triangle.v1.normal.x * lightMatrix.n31 + triangle.v1.normal.y * lightMatrix.n32 + triangle.v1.normal.z * lightMatrix.n33)*255)- p0;
		transformMatrix.c=((triangle.v2.normal.x * lightMatrix.n31 + triangle.v2.normal.y * lightMatrix.n32 + triangle.v2.normal.z * lightMatrix.n33)*255)- p0;
		transformMatrix.b=2;
		transformMatrix.d=3;
		transformMatrix.invert();
		triMatrix=sod.renderTriangleUVS[triangle] ? sod.renderTriangleUVS[triangle]:sod.getPerTriUVForShader(triangle);
		transformMatrix.concat(triMatrix);
		
		/*WORK AROUND FOR FAILING DRAWS...TAKE THIS OUT ASAP*/
		ts.graphics.clear();
		ts.graphics.beginBitmapFill(gouraudMap, transformMatrix, false,false);
		ts.graphics.drawRect(0, 0, bmp.rect.width, bmp.rect.height);
		ts.graphics.endFill();
		
		bmp.draw(ts, null,null,layerBlendMode, bmp.rect, false);
	}
	
	private function set_ambientColor(ambient:Int):Void
	{
		_ambientColor=ambient;
	}
	
	public var ambientColor(get_ambientColor, set_ambientColor):Int;
 	private function get_ambientColor():Int
	{
		return _ambientColor;
	}
	
}