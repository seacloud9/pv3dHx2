/**
* ...
* @author Default
* @version 0.1
*/

package org.papervision3d.core.effects {
import flash.filters.BitmapFilter;

import org.papervision3d.view.layer.BitmapEffectLayer;

class BitmapLayerEffect extends AbstractEffect{
	
	private var layer:BitmapEffectLayer;
	private var filter:BitmapFilter;
	public var isPostRender:Bool;
	
	public function new(filter:BitmapFilter, isPostRender:Bool=true){
		this.isPostRender=isPostRender;
		this.filter=filter;
	}
	
	public function updateEffect(filter:BitmapFilter):Void{
		this.filter=filter;
	}
	
	public override function attachEffect(layer:BitmapEffectLayer):Void{
		
		this.layer=BitmapEffectLayer(layer);
		
	}
	
	public override function preRender():Void{
		if(!isPostRender)
			layer.canvas.applyFilter(layer.canvas, layer.clippingRect, layer.clippingPoint, filter);
		
	}
	public override function postRender():Void{
		if(isPostRender)
			layer.canvas.applyFilter(layer.canvas, layer.clippingRect, layer.clippingPoint, filter);
		
	}
}