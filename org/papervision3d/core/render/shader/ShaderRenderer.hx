package org.papervision3d.core.render.shader;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.BitmapDataChannel;
import flash.display.BlendMode;
import flash.display.Sprite;
import flash.events.EventDispatcher;
import flash.geom.Point;
import flash.utils.Dictionary;

import org.papervision3d.core.render.data.RenderSessionData;
import org.papervision3d.materials.shaders.Shader;

/**
 * Author Ralph Hauwert
 */
class ShaderRenderer extends EventDispatcher implements IShaderRenderer
{
	
	public var resizedInput:Bool=false;
	public var bitmapLayer:Sprite;
	public var container:Sprite;
	public var bitmapContainer:Bitmap;
	public var shadeLayers:Dictionary;
	
	public var outputBitmap:BitmapData;
	private var _inputBitmapData:BitmapData;
	
	public function new()
	{
		container=new Sprite();

		bitmapLayer=new Sprite();
		bitmapContainer=new Bitmap();
		
		bitmapLayer.addChild(bitmapContainer);
		bitmapLayer.blendMode=BlendMode.NORMAL;
		
		shadeLayers=new Dictionary();
		container.addChild(bitmapLayer);
	}
	
	public function render(renderSessionData:RenderSessionData):Void
	{
		if(outputBitmap){
			outputBitmap.fillRect(outputBitmap.rect, 0x000000);
			bitmapContainer.bitmapData=inputBitmap;
			outputBitmap.draw(container, null, null, null, outputBitmap.rect, false);
			if(outputBitmap.transparent){
				outputBitmap.copyChannel(inputBitmap, outputBitmap.rect, new Point(0,0), BitmapDataChannel.ALPHA, BitmapDataChannel.ALPHA);
			}
		}
	}
	
	public function clear():Void
	{
		var sprite:Sprite;
		for(sprite in shadeLayers){
			if(inputBitmap && inputBitmap.width>0 && inputBitmap.height>0){
				sprite.graphics.clear();
				sprite.graphics.beginFill(0,1);
				sprite.graphics.drawRect(0,0,inputBitmap.width, inputBitmap.height);
				sprite.graphics.endFill();
			}
		}
	}
	
	public function destroy():Void
	{
		bitmapLayer=null;
		//TODO:Destroy all shaderlayers.
		outputBitmap.dispose();
	}
	
	public function getLayerForShader(shader:Shader):Sprite
	{
		var layer:Sprite=new Sprite();
		shadeLayers[shader]=layer;
		var rect:Sprite=new Sprite();
		layer.addChild(rect);
		if(inputBitmap !=null){
			rect.graphics.beginFill(0,0);
			rect.graphics.drawRect(0,0,inputBitmap.width, inputBitmap.height);
			rect.graphics.endFill();
		}
		
		container.addChild(layer);
		layer.blendMode=shader.layerBlendMode;
		
		return layer;
	}
	
	private function set_inputBitmap(bitmapData:BitmapData):Void
	{
		if(bitmapData !=null){
			if(_inputBitmapData !=bitmapData){
				_inputBitmapData=bitmapData;
				if(outputBitmap){
					if(_inputBitmapData.width !=outputBitmap.width || _inputBitmapData.height !=outputBitmap.height){
						resizedInput=true;
						outputBitmap.dispose();
						outputBitmap=_inputBitmapData.clone();
					}
				}else{
					resizedInput=true;
					outputBitmap=_inputBitmapData.clone();
				}
			}
		}
	}
	
	public var inputBitmap(get_inputBitmap, set_inputBitmap):BitmapData;
 	private function get_inputBitmap():BitmapData
	{
		return _inputBitmapData;	
	}
	
}