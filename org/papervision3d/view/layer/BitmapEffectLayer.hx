package org.papervision3d.view.layer;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;

import org.papervision3d.core.effects.AbstractEffect;
import org.papervision3d.core.effects.utils.BitmapClearMode;
import org.papervision3d.core.effects.utils.BitmapDrawCommand;
import org.papervision3d.objects.DisplayObject3D;
import org.papervision3d.view.Viewport3D;

class BitmapEffectLayer extends ViewportLayer
{
	
	public var canvas:BitmapData;
	private var transMat:Matrix;
	public var clearMode:String=BitmapClearMode.CLEAR_PRE;
	public var clippingRect:Rectangle;
	public var clippingPoint:Point;
	public var drawCommand:BitmapDrawCommand;
	public var clearBeforeRender:Bool;
	public var bitmapContainer:Bitmap;
	private var _width:Float;
	private var _height:Float;
	
	public var trackingObject:DisplayObject3D;
	public var trackingOffset:Point;
	
	public var scrollX:Float=0;
	public var scrollY:Float=0;
	
	public var effects:Array<Dynamic>;
	public var drawLayer:Sprite;
	public var renderAbove:Bool=false;
	
	public function new(viewport:Viewport3D, w:Float=640, h:Float=480, transparent:Bool=true, fillColor:Int=0, clearMode:String="clear_pre", renderAbove:Bool=false, clearBeforeRender:Bool=false)
	{
		super(viewport, new DisplayObject3D(), false);
		
		effects=new Array();
		canvas=new BitmapData(w, h, transparent, fillColor);
		
		_width=w;
		_height=h;
		
		transMat=new Matrix();
		transMat.translate(w>>1, h>>1);
		
		bitmapContainer=new Bitmap(canvas);
		addChild(bitmapContainer);
		
		bitmapContainer.x=-(w*0.5);
		bitmapContainer.y=-(h*0.5);
		
		drawLayer=new Sprite();
		addChild(drawLayer);
		
		this.graphicsChannel=drawLayer.graphics;
		
		this.clearMode=clearMode;
		
		trackingOffset=new Point();
		clippingPoint=new Point();
		clippingRect=canvas.rect;
		
		drawCommand=new BitmapDrawCommand();
		
		this.clearBeforeRender=clearBeforeRender;
		if(!renderAbove)
			setChildIndex(drawLayer, 0);
	}
	
	public function setBitmapOffset(x:Float, y:Float):Void{
		
		bitmapContainer.x=x-(_width*0.5);
		bitmapContainer.y=y-(_height*0.5);
		
		transMat=new Matrix();
		transMat.translate(_width>>1, _height>>1);
		
		transMat.translate(-x, -y);
	}
	
	public function setTracking(object:DisplayObject3D, offset:Point=null):Void{
		trackingObject=object;
		if(offset)
			trackingOffset=offset;
		else
			trackingOffset=new Point();
	}
	
	public function setScroll(x:Float=0, y:Float=0):Void{
		scrollX=x;
		scrollY=y;
	}
	
	public function fillCanvas(color:Int):Void{
		canvas.fillRect(canvas.rect, color);
	}
	
	public function renderEffects():Void{

		var drawTarget:DisplayObject=drawLayer;
		
		if(trackingObject)
			setBitmapOffset(trackingObject.screen.x+trackingOffset.x, trackingObject.screen.y+trackingOffset.y);			
		
		if(drawCommand.drawContainer){
			drawTarget=this;
		}
		
		if(scrollX !=0 || scrollY !=0)
			canvas.scroll(scrollX, scrollY);
		
		drawCommand.draw(canvas, drawTarget, transMat, clippingRect);

		for(var e:AbstractEffect in effects){
			e.postRender();
		}
		if(clearMode==BitmapClearMode.CLEAR_POST)
			drawLayer.graphics.clear();
		
	}
	public function removeEffect(fx:AbstractEffect):Void{
		

	}
	
	public function setClipping(rect:Rectangle, point:Point):Void{
		this.clippingRect=rect;
		this.clippingPoint=point;
	}
	
	public function addEffect(fx:AbstractEffect):Void{
		
		fx.attachEffect(this);
		effects.push(fx);
		
	}
	
	public override function updateBeforeRender():Void
	{
		
		if(clearBeforeRender)
			canvas.fillRect(canvas.rect, 0);

		for(var e:AbstractEffect in effects){
			e.preRender();
		}
		
		if(clearMode==BitmapClearMode.CLEAR_PRE)
			drawLayer.graphics.clear();
			
		super.updateBeforeRender();
	}
	
	public override function updateAfterRender():Void{
		//super.updateAfterRender();
		renderEffects();
	}
	
	public function getTranslationMatrix():Matrix{
		return transMat;
	}
	
}