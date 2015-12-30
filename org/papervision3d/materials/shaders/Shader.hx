package org.papervision3d.materials.shaders;

import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.display.Sprite;
import flash.events.EventDispatcher;
import flash.filters.BitmapFilter;
import flash.utils.Dictionary;

import org.papervision3d.core.geom.renderables.Triangle3D;
import org.papervision3d.core.render.data.RenderSessionData;
import org.papervision3d.core.render.shader.ShaderObjectData;
import org.papervision3d.objects.DisplayObject3D;

/**
 * @Author Ralph Hauwert
 */
class Shader extends EventDispatcher implements IShader
{
	private var _filter:BitmapFilter;
	private var _blendMode:String=BlendMode.MULTIPLY;
	private var _object:DisplayObject3D;
	private var layers:Dictionary;
	
	public function new()
	{
		super();
		this.layers=new Dictionary(true);
	}
			
	public function renderLayer(triangle:Triangle3D, renderSessionData:RenderSessionData, sod:ShaderObjectData):Void
	{
		
	}
	
	public function renderTri(triangle:Triangle3D, renderSessionData:RenderSessionData, sod:ShaderObjectData, bmp:BitmapData):Void
	{
		
	}
	
	public function destroy():Void
	{
		
	}
	
	public function setContainerForObject(object:DisplayObject3D, layer:Sprite):Void
	{
		layers[object]=layer;
	}
	
	private function set_filter(filter:BitmapFilter):Void
	{
		_filter=filter;
	}
	
	public var filter(get_filter, set_filter):BitmapFilter;
 	private function get_filter():BitmapFilter
	{
		return _filter;	
	}
	
	private function set_layerBlendMode(blendMode:String):Void
	{
		_blendMode=blendMode;
	}
	
	public var layerBlendMode(get_layerBlendMode, set_layerBlendMode):String;
 	private function get_layerBlendMode():String
	{
		return _blendMode;
	}
	
	public function updateAfterRender(renderSessionData:RenderSessionData, sod:ShaderObjectData):Void
	{
		
	}
	
}