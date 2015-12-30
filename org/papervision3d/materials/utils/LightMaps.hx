package org.papervision3d.materials.utils;

import flash.display.BitmapData;
import flash.display.GradientType;
import flash.display.Sprite;
import flash.filters.BlurFilter;
import flash.geom.Matrix;
import flash.geom.Point;

/**
 * @Author Ralph Hauwert
 */
class LightMaps
{
	private static var origin:Point=new Point();
	
	public static function getFlatMapArray(lightColor:Int, ambientColor:Int, specularLevel:Int):Array
	{
		var array:Array<Dynamic>=new Array();
		var tempmap:BitmapData=new BitmapData(256,1,false,0);
		var s:Sprite=new Sprite();
		var m:Matrix=new Matrix();
		m.createGradientBox(256,1,0,0,0);
		s.graphics.beginGradientFill(GradientType.LINEAR, [lightColor,ambientColor,ambientColor],[1,1,1],[0,255-specularLevel,255],m);
		s.graphics.drawRect(0,0,256,1);
		s.graphics.endFill();
		tempmap.draw(s);
		
		var i:Int=256;
		while(i--){
			array.push(tempmap.getPixel(i,0));
		}
	
		tempmap.dispose();

		return array;
	}
	
	public static function getFlatMap(lightColor:Int, ambientColor:Int, specularLevel:Int):BitmapData
	{
		var tempmap:BitmapData=new BitmapData(255,1,false,0);
		var s:Sprite=new Sprite();
		var m:Matrix=new Matrix();
		m.createGradientBox(255,1,0,0,0);
		s.graphics.beginGradientFill(GradientType.LINEAR, [ambientColor,ambientColor,lightColor],[1,1,1],[0,255-specularLevel,255],m);
		s.graphics.drawRect(0,0,255,1);
		s.graphics.endFill();
		tempmap.draw(s);
		return tempmap;
	}
	
	public static function getPhongMap(lightColor:Int, ambientColor:Int, specularLevel:Int, height:Int=255, width:Int=255):BitmapData
	{
		var lw:Float=height;
		var lh:Float=width;	
		var s:Sprite=new Sprite();
		var mat:Matrix=new Matrix();
		mat.createGradientBox(lw,lw,0,0,0);
		s.graphics.beginGradientFill(GradientType.RADIAL, [lightColor,ambientColor,ambientColor], [1,1,1], [0,255-specularLevel,255], mat);
		s.graphics.drawRect(0,0,lw,lw);
		s.graphics.endFill();
		var bmp:BitmapData=new BitmapData(lw,lw,false,0x0000FF);
		bmp.draw(s);
		return bmp;
	}
	
	public static function getGouraudMap(lightColor:Int, ambientColor:Int, specularLevel:Int):BitmapData
	{
		var gouraudMap:BitmapData=new BitmapData(255,3,false,0xFFFFFF);
		var s:Sprite=new Sprite();
		var m:Matrix=new Matrix();
		m.createGradientBox(255,3,0,0,0);
//			s.graphics.beginGradientFill(GradientType.LINEAR, [ambientColor,lightColor],[1,1],[0,255],m);
		s.graphics.beginGradientFill(GradientType.LINEAR, [ambientColor,ambientColor,lightColor],[1,1,1],[0,specularLevel,0xFF],m);
		s.graphics.drawRect(0,0,255,3);
		s.graphics.endFill();
		gouraudMap.draw(s);
		return gouraudMap;
	}
	
	public static function getGouraudMaterialMap(lightColor:Int, ambientColor:Int, specularLevel:Int):BitmapData
	{
		var gouraudMap:BitmapData=new BitmapData(256,3,false,0xFFFFFF);
		var s:Sprite=new Sprite();
		var m:Matrix=new Matrix();
		m.createGradientBox(256,3,0,0,0);
//			s.graphics.beginGradientFill(GradientType.LINEAR, [ambientColor,lightColor],[1,1],[0x77,0xFF],m);
		s.graphics.beginGradientFill(GradientType.LINEAR, [ambientColor,ambientColor,lightColor],[1,1,1],[0,specularLevel,0xFF],m);
		s.graphics.drawRect(0,0,256,3);
		s.graphics.endFill();
		gouraudMap.draw(s);
		return gouraudMap;
	}
	
	public static function getCellMap(color_1:Int, color_2:Int, steps:Int):BitmapData
	{
		/**
		 * Posterize Code derived from Mario Klingemann.
		 */
		var bmp:BitmapData=LightMaps.getPhongMap(color_1,color_2,0,255,255);
		var n:Float=0;
		var r_1:Int=(color_1&0xFF0000)>>16;
		var r_2:Int=(color_2&0xFF0000)>>16;
		var rStep:Int=r_2-r_1;
		var rlut:Array<Dynamic>=new Array();
  		var glut:Array<Dynamic>=new Array();
  		var blut:Array<Dynamic>=new Array();
	  	for(i in 0...255){
	  		rlut[i]=(i-(i % Math.round(256/steps)))<<16;
			glut[i]=(i-(i % Math.round(256/steps)))<<8;
			blut[i]=(i-(i % Math.round(256/steps)));
		}
		bmp.paletteMap(bmp,bmp.rect,origin, rlut, glut, blut);
		bmp.applyFilter(bmp, bmp.rect, origin, new BlurFilter(2,2,2));
		return bmp;
	}
}