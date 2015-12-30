/**
* ...
* @author Default
* @version 0.1
*/

package org.papervision3d.core.effects {
import flash.filters.ColorMatrixFilter;
import flash.geom.Point;
import org.papervision3d.view.layer.BitmapEffectLayer;


class BitmapColorEffect extends AbstractEffect{
	
	private var layer:BitmapEffectLayer;
	private var filter:ColorMatrixFilter;
	
	public function new(r:Float=1, g:Float=1, b:Float=1, a:Float=1){
		
	filter=new ColorMatrixFilter(
	[r,0,0,0,0,
	 0,g,0,0,0,
	 0,0,b,0,0,
	 0,0,0,a,0]
	);
		
	}
	
	public function updateEffect(r:Float=1, g:Float=1, b:Float=1, a:Float=1):Void{
		filter=new ColorMatrixFilter(
	[r,0,0,0,0,
	 0,g,0,0,0,
	 0,0,b,0,0,
	 0,0,0,a,0]
	);
		
	}
	public override function attachEffect(layer:BitmapEffectLayer):Void{
		
		this.layer=BitmapEffectLayer(layer);
		
	}
	public override function postRender():Void{
		
		layer.canvas.applyFilter(layer.canvas, layer.canvas.rect, new Point(), filter);
		
	}
}