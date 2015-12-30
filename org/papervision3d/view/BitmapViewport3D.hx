package org.papervision3d.view;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.events.Event;
import flash.geom.Matrix;

import org.papervision3d.core.render.data.RenderSessionData;
import org.papervision3d.core.view.IViewport3D;

/**
 * @Author Ralph Hauwert
 */
class BitmapViewport3D extends Viewport3D implements IViewport3D
{
	
	public var bitmapData		:BitmapData;
	
	public var _containerBitmap	:Bitmap;
	private var _fillBeforeRender:Bool=true;
	private var bgColor			:Int;
	private var bitmapTransparent:Bool;
	
	public function new(viewportWidth:Float=640, viewportHeight:Float=480, autoScaleToStage:Bool=false,bitmapTransparent:Bool=false, bgColor:Int=0x000000,  Interactive:Bool=false, autoCulling:Bool=true)
	{
		super(viewportWidth, viewportHeight, autoScaleToStage, Interactive, true, autoCulling);
		this.bgColor=bgColor;
		_containerBitmap=new Bitmap();
		
		bitmapData=_containerBitmap.bitmapData=new BitmapData(Math.round(viewportWidth), Math.round(viewportHeight), bitmapTransparent, bgColor);
		scrollRect=null;
		addChild(_containerBitmap);
		removeChild(_containerSprite);
	}
	
	override public function updateAfterRender(renderSessionData:RenderSessionData):Void
	{
		super.updateAfterRender(renderSessionData);
		if(bitmapData.width !=Math.round(viewportWidth)|| bitmapData.height !=Math.round(viewportHeight))
		{
			bitmapData=_containerBitmap.bitmapData=new BitmapData(Math.round(viewportWidth), Math.round(viewportHeight), bitmapTransparent, bgColor);
		}
		else
		{
			if(_fillBeforeRender){
				bitmapData.fillRect(bitmapData.rect, bgColor);
			}
		}

		var mat:Matrix=new Matrix();
		mat.translate(_hWidth, _hHeight);
		bitmapData.draw(_containerSprite, mat ,null, null, bitmapData.rect, false);
	}
	
	override private function onStageResize(event:Event=null):Void
	{
		if(_autoScaleToStage)
		{
			viewportWidth=stage.stageWidth;
			viewportHeight=stage.stageHeight;
		}
	}
	
	private function set_fillBeforeRender(value:Bool):Void
	{
		_fillBeforeRender=value;	
	}
	
	public var fillBeforeRender(get_fillBeforeRender, set_fillBeforeRender):Bool;
 	private function get_fillBeforeRender():Bool
	{
		return _fillBeforeRender;
	}
	
	override private function set_autoClipping(clip:Bool):Void
	{
		//Do nothing.
	}
	
	override public var autoClipping(get_autoClipping, set_autoClipping):Bool;
 	private function get_autoClipping():Bool
	{
		return _autoClipping;	
	}
}