/**
* ...
* @author Default
* @version 0.1
*/

package org.papervision3d.core.effects {
import org.papervision3d.view.layer.BitmapEffectLayer;

import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.filters.BlurFilter;
import flash.filters.ColorMatrixFilter;
import flash.filters.DisplacementMapFilter;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Point;	

class BitmapFireEffect extends AbstractEffect{
	
	private var layer:BitmapEffectLayer;
	private var _fadeRate:Float=0.4;
	private var _distortionScale:Float=0.4;
	private var _distortion:Float=0.5;
	private var _flameHeight:Float=0.3;
	private var _flameSpread:Float=0.3;
	private var _blueFlame:Bool=false;
	private var _smoke:Float=0;
	
// private properties:
	// display elements:
	private var displayBmp:BitmapData;
	private var scratchBmp:BitmapData;
	private var perlinBmp:BitmapData;
	
	// geom:
	private var mtx:Matrix;
	private var pnt:Point;
	private var drawColorTransform:ColorTransform;
	
	// filters:
	private var fireCMF:ColorMatrixFilter;
	private var dispMapF:DisplacementMapFilter;
	private var blurF:BlurFilter;
	
	// other
	private var endCount:Float;
	private var bmpsValid:Bool=false;
	private var perlinValid:Bool=false;
	private var filtersValid:Bool=false;
	private var _target:DisplayObject;
	
	
	public function new(r:Float=1, g:Float=1, b:Float=1, a:Float=1){
		
		
		mtx=new Matrix();
		pnt=new Point();
		
	}
	

	public override function attachEffect(layer:BitmapEffectLayer):Void{
		
		this.layer=BitmapEffectLayer(layer);
		target=layer.drawLayer;
		
	}
	
	public override function postRender():Void{
		
		doFire();
		//layer.canvas.applyFilter(layer.canvas, layer.canvas.rect, new Point(), fade);
		
	}


	 private function set_width(value:Float):Void {
		//layer.canvas.width;
	}
	 public var width(get_width, set_width):Float;
 	private function get_width():Float {
		return layer.canvas.width;
	}
	
	private function set_height(value:Float):Void {

	}
	 public var height(get_height, set_height):Float;
 	private function get_height():Float {
		return layer.canvas.height;
	}


[Inspectable(defaultValue=0.4,name='fadeRate(0-1)')]
	/**
	 * Sets the rate that flames fade as they move up. 0 is slowest, 1 is fastest.
	 *
	 * @default 0.4
	 */
	private function set_fadeRate(value:Float):Void {
		filtersValid &&=(value==_fadeRate);
		_fadeRate=value;
	}
	public var fadeRate(get_fadeRate, set_fadeRate):Float;
 	private function get_fadeRate():Float {
		return _fadeRate;
	}
	
	[Inspectable(defaultValue=0.4,name='distortionScale(0-1)')]
	/**
	 * Sets the scale of flame distortion. 0.1 is tiny and chaotic, 1 is large and smooth.
	 *
	 * @default 0.4
	 */
	private function set_distortionScale(value:Float):Void {
		perlinValid &&=(value==_distortionScale);
		_distortionScale=value;
	}
	public var distortionScale(get_distortionScale, set_distortionScale):Float;
 	public var distortion(get_distortion, set_distortion):Float;
 	private function get_distortionScale():Float {
		return _distortionScale;
	}
	
	[Inspectable(defaultValue=0.4,name='distortion(0-1)')]
	/**
	 * Sets the amount of distortion. 0.1 is little, 1 is chaotic.
	 *
	 * @default 0.4
	 */
	private function set_distortion(value:Float):Void {
		filtersValid &&=(value==_fadeRate);
		_distortion=value;
	}
	public var distortion(get_distortion, set_distortion):Float;
 	private function get_distortion():Float {
		return _distortion;
	}
	
	[Inspectable(defaultValue=0.3,name='flameHeight(0-1)')]
	/**
	 * Sets the how high the flame will burn. 0 is zero gravity, 1 is a bonfire.
	 *
	 * @default 0.3
	 */
	private function set_flameHeight(value:Float):Void {
		perlinValid &&=(value==_flameHeight);
		_flameHeight=value;
	}
	public var flameHeight(get_flameHeight, set_flameHeight):Float;
 	private function get_flameHeight():Float {
		return _flameHeight;
	}
	
	[Inspectable(defaultValue=0.3,name='flameSpread(0-1)')]
	/**
	 * Sets the how much the fire will spread out around the target. 0 is no spread, 1 is a lot.
	 *
	 * @default 0.3
	 */
	private function set_flameSpread(value:Float):Void {
		filtersValid &&=(value==_flameSpread);
		_flameSpread=value;
	}
	public var flameSpread(get_flameSpread, set_flameSpread):Float;
 	private function get_flameSpread():Float {
		return _flameSpread;
	}
	
	[Inspectable(defaultValue=false,name='blueFlame')]
	/**
	 * Indicates whether it should use a blue or red flame.
	 *
	 * @default false
	 */
	private function set_blueFlame(value:Bool):Void {
		filtersValid &&=(value==_blueFlame);
		_blueFlame=value;
	}
	public var blueFlame(get_blueFlame, set_blueFlame):Bool;
 	private function get_blueFlame():Bool {
		return _blueFlame;
	}
	
	[Inspectable(defaultValue=0,name='smoke(0-1)')]
	/**
	 * Sets the amount of smoke. 0 little, 1 lots.
	 *
	 * @default 0
	 */
	private function set_smoke(value:Float):Void {
		filtersValid &&=(value==_smoke);
		_smoke=value;
	}
	public var smoke(get_smoke, set_smoke):Float;
 	private function get_smoke():Float {
		return _smoke;
	}
	
	
	[Inspectable(defaultValue='',name='target')]
	/**
	 * Sets the amount of smoke. 0 little, 1 lots.
	 *
	 * @default 
	 */
	private function set_targetName(value:String):Void {

	}
	
	/**
	 * Defines the shape of the fire. The fire will burn upwards, so it should be near the bottom, and centered in the FireFX component.
	 *
	 * @default 
	 */
	private function set_target(value:DisplayObject):Void {
		_target=value;
		clear();
	}
	public var target(get_target, set_target):DisplayObject;
 	private function get_target():DisplayObject {
		return _target;
	}
	
	/**
	 * Clears the fire.
	 */
	public function clear():Void {
		if(displayBmp){
			displayBmp.fillRect(displayBmp.rect,0);
		}
	}
	

	
	public function stopFire():Void {
		// let the fire burn down for 20 frames:
		if(endCount==0){ endCount=20;}
	}
	
	
	private function updateBitmaps():Void {
		if(displayBmp){
			displayBmp.dispose();
			displayBmp=null;
			scratchBmp.dispose();
			scratchBmp=null;
			perlinBmp.dispose();
			perlinBmp=null;
		}
		
		displayBmp=layer.canvas;
		scratchBmp=displayBmp.clone();
		perlinBmp=new BitmapData(width*3, height*3, false, 0);
		
		
		updatePerlin();
		updateFilters();
		bmpsValid=true;
	}
	
	private function updatePerlin():Void {
		perlinBmp.perlinNoise(30*_distortionScale,20*_distortionScale,1,-Math.random()*1000|0,false,true,1|2,false);
		perlinBmp.colorTransform(perlinBmp.rect,new ColorTransform(1,  1-_flameHeight*0.5  ,1,1,0,0,0,0));
		perlinValid=true;
	}
	
	private function updateFilters():Void {
		if(_blueFlame){
			fireCMF=new ColorMatrixFilter([0.8-0.55*_fadeRate,0,0,0,0,
											 0,0.93-0.48*_fadeRate,0,0,0,
											 0,0.1,0.96-0.35*_fadeRate,0,0,
											 0,0.1,0,1,-25+_smoke*24]);
			drawColorTransform=new ColorTransform(0,0,0,1,210,240,255,0);
		} else {
			fireCMF=new ColorMatrixFilter([0.96-0.35*_fadeRate,0.1,0,0,-1,
											 0,0.9-0.45*_fadeRate,0,0,0,
											 0,0,0.8-0.55*_fadeRate,0,0,
											 0,0.1,0,1,-25+_smoke*24]);
			drawColorTransform=new ColorTransform(0,0,0,1,255,255,210,0);
		}
		dispMapF=new DisplacementMapFilter(perlinBmp,pnt,1,2,14*_distortion,-30,"clamp");
		blurF=new BlurFilter(32*_flameSpread,32*_flameSpread,1);
		
		filtersValid=true;
	}
	
	
	
	private function startFire():Void {
		endCount=0;
		
	}
	
	private function doFire():Void {
		if(_target==null){ return;}
		if(!bmpsValid){ updateBitmaps();}
		if(!perlinValid){ updatePerlin();}
		if(!filtersValid){ updateFilters();}
		if(endCount==0){
			var drawMtx:Matrix=_target.transform.matrix;

			scratchBmp.fillRect(scratchBmp.rect,0);
			drawColorTransform.alphaOffset=-Math.random()*200|0;
			scratchBmp.draw(_target,drawMtx,drawColorTransform,"add");
			scratchBmp.applyFilter(scratchBmp,scratchBmp.rect,pnt,blurF);
			displayBmp.draw(scratchBmp,mtx,null,"add");
		}
		dispMapF.mapPoint=new Point(-Math.random()*(perlinBmp.width-displayBmp.width)|0, -Math.random()*(perlinBmp.height-displayBmp.height)|0);
		displayBmp.applyFilter(displayBmp,displayBmp.rect,pnt,dispMapF);
		displayBmp.applyFilter(displayBmp,displayBmp.rect,pnt,fireCMF);
		
		//if(endCount !=0 && --endCount==0){
		//	removeEventListener(Event.ENTER_FRAME,doFire);
		}
	}