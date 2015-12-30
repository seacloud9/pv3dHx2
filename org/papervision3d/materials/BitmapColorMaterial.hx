package org.papervision3d.materials;

import flash.display.BitmapData;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.geom.Matrix;

import org.papervision3d.core.render.command.RenderTriangle;
import org.papervision3d.core.render.data.RenderSessionData;
import org.papervision3d.core.render.draw.ITriangleDrawer;

class BitmapColorMaterial extends BitmapMaterial implements ITriangleDrawer
{
	private var uvMatrix:Matrix;
	
	private static inline var BITMAP_WIDTH:Int=16;
	private static inline var BITMAP_HEIGHT:Int=16;
	
	public function new(color:Float=0xFF00FF, alpha:Float=1)
	{
		bitmap=new BitmapData(BITMAP_WIDTH,BITMAP_HEIGHT,fillAlpha>1,0x00000000);
		fillColor=color;
		fillAlpha=alpha;
		precise=false;
		init();
	}
	
	private function init():Void
	{
		createBitmapData();
		createStaticUVMatrix();
	}
	
	override public function drawTriangle(tri:RenderTriangle, graphics:Graphics, renderSessionData:RenderSessionData,altBitmap:BitmapData=null, altUV:Matrix=null):Void
	{
		if(bitmap){
			var x0:Float=tri.v0.x;
			var y0:Float=tri.v0.y;
			var x1:Float=tri.v1.x;
			var y1:Float=tri.v1.y;
			var x2:Float=tri.v2.x;
			var y2:Float=tri.v2.y;
			
			_triMatrix.a=x1 - x0;
			_triMatrix.b=y1 - y0;
			_triMatrix.c=x2 - x0;
			_triMatrix.d=y2 - y0;
			_triMatrix.tx=x0;
			_triMatrix.ty=y0;
				
			_localMatrix.a=uvMatrix.a;
			_localMatrix.b=uvMatrix.b;
			_localMatrix.c=uvMatrix.c;
			_localMatrix.d=uvMatrix.d;
			_localMatrix.tx=uvMatrix.tx;
			_localMatrix.ty=uvMatrix.ty;
			_localMatrix.concat(_triMatrix);
			
			graphics.beginBitmapFill(bitmap, _localMatrix, tiled, smooth);
			graphics.moveTo(x0, y0);
			graphics.lineTo(x1, y1);
			graphics.lineTo(x2, y2);
			graphics.lineTo(x0, y0);
			graphics.endFill();
			renderSessionData.renderStatistics.triangles++;
		}
		
	}
	
	private function createBitmapData():Void
	{
		var sprite:Sprite=new Sprite();
		var graphics:Graphics=sprite.graphics;
		graphics.beginFill(fillColor, fillAlpha);
		graphics.drawRect(0,0,BITMAP_WIDTH,BITMAP_HEIGHT);
		graphics.endFill();
		bitmap.draw(sprite);
	}
	
	private function createStaticUVMatrix():Void
	{
		var w:Float=BITMAP_WIDTH;
		var h:Float=BITMAP_HEIGHT;

		var u0:Float=w;
		var v0:Float=0;
		var u1:Float=0;
		var v1:Float=0;
		var u2:Float=w;
		var v2:Float=h;
		
		// Precalculate matrix & correct for mip mapping
		var at:Float=(u1 - u0);
		var bt:Float=(v1 - v0);
		var ct:Float=(u2 - u0);
		var dt:Float=(v2 - v0);

		uvMatrix=new Matrix(at, bt, ct, dt, u0, v0);
		uvMatrix.invert();
	}
	
	

}