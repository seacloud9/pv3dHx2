package org.papervision3d.materials;

import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.Stage;
import flash.geom.Matrix;
import flash.geom.Rectangle;

import org.papervision3d.core.log.PaperLogger;
import org.papervision3d.core.render.command.RenderTriangle;
import org.papervision3d.core.render.data.RenderSessionData;
import org.papervision3d.core.render.draw.ITriangleDrawer;
import org.papervision3d.core.render.material.IUpdateAfterMaterial;
import org.papervision3d.core.render.material.IUpdateBeforeMaterial;	

/**
 * The MovieMaterial class creates a texture from an existing MovieClip instance.
*<p/>
* The texture can be animated and/or transparent. Current scale and color values of the MovieClip instance will be used. Rotation will be discarded.
*<p/>
* Materials collects data about how objects appear when rendered.
*/
class MovieMaterial extends BitmapMaterial implements ITriangleDrawer, IUpdateBeforeMaterial, IUpdateAfterMaterial
{
	// ______________________________________________________________________ PUBLIC
	private var recreateBitmapInSuper:Bool;
	
	private var materialIsUsed:Bool=false;
	/**
	* The MovieClip that is used as a texture.
	*/
	public var movie:DisplayObject;

	/**
	* A Bool value that determines whether the MovieClip is transparent. The default value is false, which is much faster.
	*/
	public var movieTransparent:Bool;
	
	/**
	* When updateBitmap()is called on an animated material, it looks to handle a change in size on the texture.
	* 
	* This is true by default, but in certain situations, like drawing on an object, you wouldn't want the size to change
	*/
	public var allowAutoResize:Bool=false;

	// ______________________________________________________________________ ANIMATED

	/**
	* A Bool value that determines whether the texture is animated.
	*
	* If set, the material must be included Into the scene so the BitmapData texture can be updated when rendering. For performance reasons, the default value is false.
	*/
	public var animated(get_animated, set_animated):Bool;
 	private function get_animated():Bool
	{
		return movieAnimated;
	}

	private function set_animated(status:Bool):Void
	{
		movieAnimated=status;
	}
	
	/**
	* A texture object.
	*/		
	override public var texture(get_texture, set_texture):Dynamic;
 	private function get_texture():Dynamic
	{
		return this._texture;
	}
	/**
	* @private
	*/
	override private function set_texture(asset:Dynamic):Void
	{
		if(Std.is(asset, DisplayObject)==false)
		{
			PaperLogger.error("MovieMaterial.texture requires a Sprite to be passed as the object");
			return;
		}
		bitmap=createBitmapFromSprite(DisplayObject(asset));
		_texture=asset;
	}

	// ______________________________________________________________________ RECT

	/**
	*  Rectangle object that defines the area of the source object to draw.
	*  
	*  When present, this property defines bitmap size overriding allowAutoResize.
	*
	*  If you do not supply this value, no clipping occurs and the entire source object is drawn.
	*  
	*/
	public var rect(get_rect, set_rect):Rectangle;
 	private function get_rect():Rectangle
	{
		var clipRect:Rectangle=userClipRect || autoClipRect;
		
		if(! clipRect && movie)clipRect=movie.getBounds(movie);
		
		return clipRect;
	}

	private function set_rect(clipRect:Rectangle):Void
	{
		userClipRect=clipRect;
		createBitmapFromSprite(movie);
	}

	// ______________________________________________________________________ PRIVATE

	private var userClipRect			:Rectangle;
	private var autoClipRect			:Rectangle;
	private var movieAnimated			:Bool;
	private var quality					:String;
	private var stage					:Stage;

	// ______________________________________________________________________ NEW

	/**
	* The MovieMaterial class creates a texture from an existing MovieClip instance.
	*
	* @param	movieAsset		A reference to an existing MovieClip loaded Into memory or on stage
	* @param	transparent		[optional] - If it's not transparent, the empty areas of the MovieClip will be of fill32 color. Default value is false.
	* @param	animated		[optional] - a flag setting whether or not this material has animation.  If set to true, it will be updated during each render loop
	*/
	public function new(movieAsset:DisplayObject=null, transparent:Bool=false, animated:Bool=false, precise:Bool=false, rect:Rectangle=null)
	{
		movieTransparent=transparent;
		this.animated=animated;
		this.precise=precise;
		userClipRect=rect;

		if(movieAsset)texture=movieAsset;
	}
	
	// ______________________________________________________________________ CREATE BITMAP

	/**
	* 
	* @param	asset
	* @return
	*/
	private function createBitmapFromSprite(asset:DisplayObject):BitmapData
	{
		// Set the new movie reference
		movie=asset;
		
		// initialize the bitmap since it's new
		initBitmap(movie);
		
		// Draw
		drawBitmap();

		// Call super.createBitmap to centralize the bitmap specific code.
		// Here only MovieClip specific code, all bitmap code(maxUVs, AUTO_MIP_MAP, correctBitmap)in BitmapMaterial.
		bitmap=super.createBitmap(bitmap);

		return bitmap;
	}
	
	private function initBitmap(asset:DisplayObject):Void
	{
		// Cleanup previous bitmap if needed
		if(bitmap)
			bitmap.dispose();
		
		// Create new bitmap
		if(userClipRect){
			bitmap=new BitmapData(int(userClipRect.width+0.5), Std.int(userClipRect.height+0.5), movieTransparent, fillColor);
		}else if(asset.width==0 || asset.height==0){
			bitmap=new BitmapData(256, 256, movieTransparent, fillColor);
		}else{
			bitmap=new BitmapData(int(asset.width+0.5), Std.int(asset.height+0.5), movieTransparent, fillColor);
		}
	}
	
	override public function drawTriangle(tri:RenderTriangle, graphics:Graphics, renderSessionData:RenderSessionData, altBitmap:BitmapData=null, altUV:Matrix=null):Void
	{
		materialIsUsed=true;
		super.drawTriangle(tri, graphics, renderSessionData, altBitmap, altUV);
	}

	
	// ______________________________________________________________________ UPDATE
	/**
	* Updates animated MovieClip bitmap.
	*
	* Draws the current MovieClip image onto bitmap.
	*/
	public function updateBeforeRender(renderSessionData:RenderSessionData):Void
	{
		materialIsUsed=false;
		if(movieAnimated){
			// using Int is much faster than using Math.floor. And casting the variable saves in speed from having the avm decide what to cast it as
			var mWidth:Int;
			var mHeight:Int;

			if(userClipRect)
			{
				mWidth=Std.int(userClipRect.width+0.5);
				mHeight=Std.int(userClipRect.height+0.5);
			}
			else
			{
				mWidth=Std.int(movie.width+0.5);
				mHeight=Std.int(movie.height+0.5);
			}
			
			
			if(allowAutoResize &&(mWidth !=bitmap.width || mHeight !=bitmap.height))
			{
				initBitmap(movie);
				recreateBitmapInSuper=true;
			}
			
		}		
	}
	
	public function updateAfterRender(renderSessionData:RenderSessionData):Void
	{
		if(movieAnimated==true && materialIsUsed==true){
			drawBitmap();
			if(recreateBitmapInSuper){
				bitmap=super.createBitmap(bitmap);
				recreateBitmapInSuper=false;
			}
		}	
	}
	
	public function drawBitmap():Void
	{
		// Clear bitmap
		bitmap.fillRect(bitmap.rect, fillColor);

		// Set quality
		if(stage && quality)
		{
			var stageQuality:String=stage.quality;
			stage.quality=quality;
		}

		// Clip rectangle
		var clipRect:Rectangle=rect;
		var trans:Matrix=new Matrix(1, 0, 0, 1, -clipRect.x, -clipRect.y);

		// Draw
		bitmap.draw(movie, trans, movie.transform.colorTransform, null);

		// Update rectangle
		if(! userClipRect)autoClipRect=movie.getBounds(movie);

		// Restore quality
		if(stage && quality)stage.quality=stageQuality;
	}

	// ______________________________________________________________________ QUALITY

	/**
	* Specifies which rendering quality Flash Player uses when drawing the bitmap texture from the movie asset.
	* 
	* If not set, bitmaps are drawn using the current stage quality setting.
	*/
	public function setQuality(quality:String, stage:Stage, updateNow:Bool=true):Void
	{
		this.quality=quality;
		this.stage=stage;

		if(updateNow)
			createBitmapFromSprite(movie);
	}
}