package org.papervision3d.core.effects.objects;

import flash.display.BlendMode;
import flash.display.DisplayObject;

import org.papervision3d.core.proto.LightObject3D;
import org.papervision3d.objects.DisplayObject3D;
import org.papervision3d.view.layer.ViewportLayer;

class LensFlare extends ViewportLayer
{
	
	public var light:LightObject3D;

	public var flareWidth:Float=0;
	public var flareHeight:Float=0;
	
	public var edgeOffset:Float=1.15;
	private var flareArray:Array<Dynamic>;
	
	
	public function new(light:LightObject3D, flareArray:Array, width:Float, height:Float, positions:Array<Dynamic>=null)
	{
		super(null, light, false);	
		this.light=light;
		flareWidth=width;
		flareHeight=height;

		if(positions)
			this.positions=positions;
			
		setFlareArray(flareArray);

	}
	
	public function setFlareArray(flareArray:Array):Void{
		emptyFlareArray();
		this.flareArray<Dynamic>=flareArray<Dynamic>;
		buildFlareArray();
	}
	
	private function emptyFlareArray():Void{
		for(var f:DisplayObject in flareArray){
			this.removeChild(f);
		}
		flareArray<Dynamic>=null;
	}
	
	private function buildFlareArray():Void{

		
		for(var f:DisplayObject in flareArray){
			this.addChild(f);
			f.visible=false;
			f.blendMode=BlendMode.ADD;
		}
	}
	
	public function updateFlare(showFlare:Bool=true, testHit:DisplayObject=null):Void{
		if(showFlare){
		
			//check to see if it hits anything
			if(testHit){
				 var lx:Float=Std.int(light.screen.x+flareWidth*0.5);
	   			 var ly:Float=Std.int(light.screen.y+flareHeight*0.5);
	   			 if(testHit.hitTestPoint(lx, ly, true)){
	   			 	hideFlare();
	   			 	return;
	   			 }
			}
			
			drawFlare();
		}else
			hideFlare();
	}
	
	public function hideFlare():Void{
		
		for(var f:DisplayObject in flareArray){
			f.visible=false;
		}
	}
	
	private function drawFlare():Void{
		
		
		//don't draw light if behind camera
		if(light.screen.z<=0){
			hideFlare();
			return;
		}
		
		var w:Float=flareWidth*0.5;
		var h:Float=flareHeight*0.5;
		var lx:Float=light.screen.x;
		var ly:Float=light.screen.y;
		
		var alx:Float=Math.abs(lx);
		var aly:Float=Math.abs(ly);
		
		
		
		if(alx>w*edgeOffset || aly>h*edgeOffset){
			hideFlare();
			return;
		}
		
		
		
		var distance:Float=Math.sqrt(lx*lx+ly*ly);
		var angle:Float=Math.atan2(ly, lx);
		
		var f:DisplayObject;
		var pos:Dynamic;
		var dx:Float;
		var dy:Float;
		var scaleX:Float;
		var scaleY:Float;
		var scale:Float;
		
		
		for(i in 0...flareArray.length){
			
			f=flareArray[i] as DisplayObject;
			pos=positions[i];
			
			f.visible=true;
			
			dx=Math.cos(angle)*pos.distance*distance;
			dy=Math.sin(angle)*pos.distance*distance;
			
			scaleX=scaleY=pos.scale;
		
			
			if(pos.dScale){
				scaleX +=((Math.abs(dx))/w)*pos.dScale;
				scaleY +=((Math.abs(dy))/h)*pos.dScale;
			}
			
			scale=Math.max(scaleX, scaleY);
			
			f.scaleX=f.scaleY=scale;
			
			if(pos.rotate)
				f.rotation=angle*(180/Math.PI)-180;
			
			f.x=dx;
			f.y=dy;
			
			
			
			if(pos.alpha)
				f.alpha=1 - Math.max(alx/w, aly/h)*pos.alpha;
			
		}
		
	}
	
	//VARS FOR POSITIONS:
	//distance:relative to light projected distance from center
	//scale:initial scaled size
	//dScale:how much it scales in addition based on light distance
	//alpha:how transparent
	//rotate:rotate to always have left side pointing towards center
	
	public var positions:Array<Dynamic>=
	[
	 {distance:1, scale:1, dScale:0, alpha:0},
	 {distance:1.24, scale:0.85, dScale:0, alpha:0.5},
	 {distance:0.5, scale:0.5, dScale:0, alpha:0.5},
	 {distance:0.33, scale:0.25, dScale:0, alpha:0.8},
	 {distance:0.125, scale:1, dScale:0, alpha:0.8},
	 {distance:-0.181818, scale:0.25, dScale:1.2, alpha:0.9},
	 {distance:-0.25, scale:0.25, dScale:1.5, alpha:0.8, rotate:true},
	 {distance:-0.5, scale:0.5, dScale:1.1, alpha:0.9}
	
	];

}