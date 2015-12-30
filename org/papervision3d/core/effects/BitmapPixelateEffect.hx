/**
* ...
* @author Default
* @version 0.1
*/

package org.papervision3d.core.effects {
import flash.display.BitmapData;
import flash.geom.Rectangle;
import org.papervision3d.view.layer.BitmapEffectLayer;

class BitmapPixelateEffect extends AbstractEffect{
	
	private var layer:BitmapEffectLayer;
	public var size:Int;
	
	public function new(size:Int=4){
		
		this.size=size;
	}

	
	public override function attachEffect(layer:BitmapEffectLayer):Void{
		
		this.layer=BitmapEffectLayer(layer);
		
	}
	public override function preRender():Void{
		
		
	}
	
	public override function postRender():Void{
		
		if(size<=1)
			return;
		
		var xs:Float=Math.ceil(layer.canvas.width/size);
		var ys:Float=Math.ceil(layer.canvas.height/size);
		
		var xPos:Float=1;
		var yPos:Float=1;
		
		var rect:Rectangle=new Rectangle(1, 1, size, size);
		var canvas:BitmapData=layer.canvas;
		
		for(i in 0...xs){
			for(j in 0...ys){
				xPos=i*size+1;
				yPos=j*size+1;
				rect.x=xPos-size/2;
				rect.y=yPos-size/2;
				canvas.fillRect(rect, canvas.getPixel32(xPos, yPos));
				
			}
		}			
	}
}