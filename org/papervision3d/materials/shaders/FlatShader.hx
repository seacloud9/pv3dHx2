package org.papervision3d.materials.shaders;

import flash.display.BitmapData;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.geom.Matrix;

import org.papervision3d.core.geom.renderables.Triangle3D;
import org.papervision3d.core.math.Matrix3D;
import org.papervision3d.core.proto.LightObject3D;
import org.papervision3d.core.render.data.RenderSessionData;
import org.papervision3d.core.render.shader.ShaderObjectData;
import org.papervision3d.materials.utils.LightMaps;

/**
 * @Author Ralph Hauwert
 */
class FlatShader extends LightShader implements IShader, ILightShader
{
	
	private static var triMatrix:Matrix=new Matrix();
	private static var currentGraphics:Graphics;
	private static var zAngle:Float;
	private static var currentColor:Int;
	
	private static var vx:Float;
	private static var vy:Float;
	private static var vz:Float;
	
	public var lightColor:Int;
	public var ambientColor:Int;
	public var specularLevel:Int;
	private var _colors:Array<Dynamic>;
	private var _colorRamp:BitmapData;
	
	public function new(light:LightObject3D, lightColor:Int=0xFFFFFF, ambientColor:Int=0x000000, specularLevel:Int=0)
	{
		super();
		this.light=light;
		this.lightColor=lightColor;
		this.ambientColor=ambientColor;
		this.specularLevel=specularLevel;
		this._colors=LightMaps.getFlatMapArray(lightColor, ambientColor, specularLevel);
		this._colorRamp=LightMaps.getFlatMap(lightColor, ambientColor, specularLevel);
	}
	
	/**
	 * Localized vars
	 */
	private static var zd:Float;
	private static var lightMatrix:Matrix3D;
	private static var sod:ShaderObjectData;
	
	override public function renderLayer(triangle:Triangle3D, renderSessionData:RenderSessionData, sod:ShaderObjectData):Void
	{
		lightMatrix=Matrix3D(sod.lightMatrices[this]);
		zd=triangle.faceNormal.x * lightMatrix.n31 + triangle.faceNormal.y * lightMatrix.n32 + triangle.faceNormal.z * lightMatrix.n33;
		if(zd<0){
			zd=0;
		};
		zd=zd*0xFF;
		triMatrix=sod.uvMatrices[triangle] ? sod.uvMatrices[triangle]:sod.getUVMatrixForTriangle(triangle);
		currentColor=_colors[int(zd)];
		
		currentGraphics=Sprite(layers[sod.object]).graphics;
		currentGraphics.beginFill(currentColor,1);
		currentGraphics.moveTo(triMatrix.tx, triMatrix.ty);
		currentGraphics.lineTo(triMatrix.a+triMatrix.tx, triMatrix.b+triMatrix.ty);
		currentGraphics.lineTo(triMatrix.c+triMatrix.tx, triMatrix.d+triMatrix.ty);
		currentGraphics.lineTo(triMatrix.tx, triMatrix.ty);
		currentGraphics.endFill();
	}
	
	/**
	 *Localized var
	 */
	public static var scaleMatrix:Matrix=new Matrix();
	override public function renderTri(triangle:Triangle3D, renderSessionData:RenderSessionData, sod:ShaderObjectData,bmp:BitmapData):Void
	{
		lightMatrix=Matrix3D(sod.lightMatrices[this]);
		if(lightMatrix){
			zd=triangle.faceNormal.x * lightMatrix.n31 + triangle.faceNormal.y * lightMatrix.n32 + triangle.faceNormal.z * lightMatrix.n33;
			if(zd<0){zd=0;};
			scaleMatrix.a=bmp.width;
			scaleMatrix.d=bmp.height;
			scaleMatrix.tx=-int(zd*0xFF)*bmp.width;
			bmp.draw(_colorRamp, scaleMatrix,null,layerBlendMode, bmp.rect, false);
		}
	}
}