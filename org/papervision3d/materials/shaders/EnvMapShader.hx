package org.papervision3d.materials.shaders;

import flash.display.BitmapData;
import flash.display.BitmapDataChannel;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.filters.DisplacementMapFilter;
import flash.filters.DisplacementMapFilterMode;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;

import org.papervision3d.core.geom.renderables.Triangle3D;
import org.papervision3d.core.geom.renderables.Vertex3DInstance;
import org.papervision3d.core.math.Matrix3D;
import org.papervision3d.core.math.Number3D;
import org.papervision3d.core.proto.LightObject3D;
import org.papervision3d.core.render.data.RenderSessionData;
import org.papervision3d.core.render.shader.ShaderObjectData;
import org.papervision3d.materials.utils.BumpmapGenerator;

/**
 * @Author Ralph Hauwert
 */
class EnvMapShader extends LightShader implements IShader
{
	private var lightmapHalfwidth:Float;
	private var lightmapHalfheight:Float;
	
	private var dFilter:DisplacementMapFilter;
	private var _envMap:BitmapData;
	private var _backEnvMap:BitmapData;
	private var _specularMap:BitmapData;
	private var _bumpMap:BitmapData;
	private var _ambientColor:Int;
	
	private static var mapOrigin:Point=new Point(0,0);
	private static var origin:Point=new Point(0,0);
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
	private static var v0x:Float;
	private static var v0y:Float;
	private static var v0z:Float;
	private static var v1x:Float;
	private static var v1y:Float;
	private static var v1z:Float;
	private static var v2x:Float;
	private static var v2y:Float;
	private static var v2z:Float;
	private static var sod:ShaderObjectData;
	private static var n0:Float3D;
	private static var n1:Float3D;
	private static var n2:Float3D;
	private static var r:Rectangle;
	private static var lm:Matrix3D;
	
	public function new(light:LightObject3D, envmap:BitmapData, backenvmap:BitmapData=null, ambientColor:Int=0x000000, bumpMap:BitmapData=null, specularMap:BitmapData=null)
	{
		super();
		this.light=light;
		this.envMap=envmap;
		if(!backenvmap){
			this.backenvmap=this.envMap.clone();
			this.backenvmap.fillRect(this.backenvmap.rect, ambientColor);
		}else{
			this.backenvmap=backenvmap;
		}
		this.specularMap=specularMap;
		this.bumpmap=bumpMap;
		this.ambientColor=ambientColor;	
	}
	
	/**
	 * Localized stuff.
	 */
	private static var useMap:BitmapData;
	override public function renderLayer(triangle:Triangle3D, renderSessionData:RenderSessionData, sod:ShaderObjectData):Void
	{
		lm=Matrix3D(sod.lightMatrices[this]);
		
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
		
		p0=lightmapHalfwidth*(triangle.v0.normal.x * lm.n11 + triangle.v0.normal.y * lm.n12 + triangle.v0.normal.z * lm.n13)+lightmapHalfwidth;
		q0=lightmapHalfheight*(triangle.v0.normal.x * lm.n21 + triangle.v0.normal.y * lm.n22 + triangle.v0.normal.z * lm.n23)+lightmapHalfheight;
		p1=lightmapHalfwidth*(triangle.v1.normal.x * lm.n11 + triangle.v1.normal.y * lm.n12 + triangle.v1.normal.z * lm.n13)+lightmapHalfwidth;
		q1=lightmapHalfheight*(triangle.v1.normal.x * lm.n21 + triangle.v1.normal.y * lm.n22 + triangle.v1.normal.z * lm.n23)+lightmapHalfheight;
		p2=lightmapHalfwidth*(triangle.v2.normal.x * lm.n11 + triangle.v2.normal.y * lm.n12 + triangle.v2.normal.z * lm.n13)+lightmapHalfwidth;
		q2=lightmapHalfheight*(triangle.v2.normal.x * lm.n21 + triangle.v2.normal.y * lm.n22 + triangle.v2.normal.z * lm.n23)+lightmapHalfheight;
		
		triMatrix=sod.uvMatrices[triangle] ? sod.uvMatrices[triangle]:sod.getUVMatrixForTriangle(triangle);	
		transformMatrix.tx=p0;
		transformMatrix.ty=q0;
		transformMatrix.a=p1 - p0;
		transformMatrix.b=q1 - q0;
		transformMatrix.c=p2 - p0;
		transformMatrix.d=q2 - q0;
		transformMatrix.invert();
		transformMatrix.concat(triMatrix);
		if(triangle.faceNormal.x * lm.n31 + triangle.faceNormal.y * lm.n32 + triangle.faceNormal.z * lm.n33>0){
			useMap=_envMap;
		}else{
			useMap=backenvmap;
		}
		currentGraphics=Sprite(layers[sod.object]).graphics;
		currentGraphics.beginBitmapFill(useMap, transformMatrix,false,false);
		currentGraphics.moveTo(triMatrix.tx, triMatrix.ty);
		currentGraphics.lineTo(triMatrix.a+triMatrix.tx, triMatrix.b+triMatrix.ty);
		currentGraphics.lineTo(triMatrix.c+triMatrix.tx, triMatrix.d+triMatrix.ty);
		currentGraphics.lineTo(triMatrix.tx, triMatrix.ty);
		currentGraphics.endFill();
		currentGraphics.lineStyle();
	}
	
	private static var ts:Sprite=new Sprite();
	override public function renderTri(triangle:Triangle3D, renderSessionData:RenderSessionData, sod:ShaderObjectData,bmp:BitmapData):Void
	{
		lm=Matrix3D(sod.lightMatrices[this]);
		
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
		
		p0=lightmapHalfwidth*(triangle.v0.normal.x * lm.n11 + triangle.v0.normal.y * lm.n12 + triangle.v0.normal.z * lm.n13)+lightmapHalfwidth;
		q0=lightmapHalfheight*(triangle.v0.normal.x * lm.n21 + triangle.v0.normal.y * lm.n22 + triangle.v0.normal.z * lm.n23)+lightmapHalfheight;
		p1=lightmapHalfwidth*(triangle.v1.normal.x * lm.n11 + triangle.v1.normal.y * lm.n12 + triangle.v1.normal.z * lm.n13)+lightmapHalfwidth;
		q1=lightmapHalfheight*(triangle.v1.normal.x * lm.n21 + triangle.v1.normal.y * lm.n22 + triangle.v1.normal.z * lm.n23)+lightmapHalfheight;
		p2=lightmapHalfwidth*(triangle.v2.normal.x * lm.n11 + triangle.v2.normal.y * lm.n12 + triangle.v2.normal.z * lm.n13)+lightmapHalfwidth;
		q2=lightmapHalfheight*(triangle.v2.normal.x * lm.n21 + triangle.v2.normal.y * lm.n22 + triangle.v2.normal.z * lm.n23)+lightmapHalfheight;
		
		triMatrix=sod.renderTriangleUVS[triangle] ? sod.renderTriangleUVS[triangle]:sod.getPerTriUVForShader(triangle);
		transformMatrix.tx=p0;
		transformMatrix.ty=q0;
		transformMatrix.a=p1 - p0;
		transformMatrix.b=q1 - q0;
		transformMatrix.c=p2 - p0;
		transformMatrix.d=q2 - q0;
		transformMatrix.invert();
		transformMatrix.concat(triMatrix);
		if(triangle.faceNormal.x * lm.n31 + triangle.faceNormal.y * lm.n32 + triangle.faceNormal.z * lm.n33>0){
			useMap=_envMap;
		}else{
			useMap=backenvmap;
		}
		
		/*WORK AROUND FOR FAILING DRAWS...TAKE THIS OUT ASAP*/
		ts.graphics.clear();
		ts.graphics.beginBitmapFill(useMap, transformMatrix, false,false);
		ts.graphics.drawRect(0, 0, bmp.rect.width, bmp.rect.height);
		ts.graphics.endFill();
		bmp.draw(ts, null,null,layerBlendMode, null,false);
	}
	
	override public function updateAfterRender(renderSessionData:RenderSessionData, sod:ShaderObjectData):Void
	{
		if(dFilter){
			var s:Sprite=Sprite(layers[sod.object]);
			s.filters=[dFilter];
		}
	}
	
	private function set_bumpmap(bumpmap:BitmapData):Void
	{
		if(_bumpMap){
			dFilter=null;
		}
		if(bumpmap){
			var map:BitmapData=BumpmapGenerator.generateBumpmapFrom(bumpmap);
			dFilter=new DisplacementMapFilter(map,mapOrigin,BitmapDataChannel.RED,BitmapDataChannel.GREEN,-127,-127,DisplacementMapFilterMode.WRAP,ambientColor,0);
			
		}else{
			filter=null;
		}
		_bumpMap=bumpmap;
	}
	
	public var bumpmap(get_bumpmap, set_bumpmap):BitmapData;
 	private function get_bumpmap():BitmapData
	{
		return _bumpMap;
	}
	
	private function set_envMap(lightMap:BitmapData):Void
	{
		if(lightMap){
			lightmapHalfwidth=lightMap.width/2;
			lightmapHalfheight=lightMap.height/2;
		}
		_envMap=lightMap;
	}

	public var envMap(get_envMap, set_envMap):BitmapData;
 	private function get_envMap():BitmapData
	{
		return _envMap;
	}
	
	private function set_specularMap(specularMap:BitmapData):Void
	{
		_specularMap=specularMap;
	}
	
	public var specularMap(get_specularMap, set_specularMap):BitmapData;
 	private function get_specularMap():BitmapData
	{
		return _specularMap;
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
	
	private function set_backenvmap(envmap:BitmapData):Void
	{
		_backEnvMap=envmap;
	}
	
	public var backenvmap(get_backenvmap, set_backenvmap):BitmapData;
 	private function get_backenvmap():BitmapData
	{
		return _backEnvMap;	
	}
	
}