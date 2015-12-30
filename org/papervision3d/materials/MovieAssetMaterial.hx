package org.papervision3d.materials;

import flash.display.MovieClip;
import flash.display.Sprite;
import flash.utils.getDefinitionByName;

import org.papervision3d.core.log.PaperLogger;
import org.papervision3d.core.render.draw.ITriangleDrawer;


/**
* The MovieAssetMaterial class creates a texture from a MovieClip library symbol.
*<p/>
* The texture can be animated and/or transparent.
*<p/>
* The MovieClip's content needs to be top left aligned with the registration point.
*<p/>
* Materials collects data about how objects appear when rendered.
*/
class MovieAssetMaterial extends MovieMaterial implements ITriangleDrawer
{
	
	private static var _library:Dynamic=new Dynamic();
	private static var _count:Dynamic=new Dynamic();
	
	/**
	 * By default, a MovieAssetMaterial is stored and resused, but there are times where a user may want a unique copy.  set to true if you want a unique instance
	 * created
	 */
	public var createUnique:Bool=false;
	
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
		if(Std.is(asset, String)==false)
		{
			PaperLogger.error("Error:MovieAssetMaterial.texture requires a String to be passed to create the MovieClip reference from the library");
			return;
		}
		
		movie=Sprite(createMovie(String(asset)));
		bitmap=createBitmapFromSprite(movie);
		_texture=asset;
	}

	// ______________________________________________________________________ NEW

	/**
	* The MovieAssetMaterial class creates a texture from a MovieClip library id.
	*
	* @param	linkageID			The linkage name of the MovieClip symbol in the library.
	* @param	transparent			[optional] - If it's not transparent, the empty areas of the MovieClip will be of fill32 color. Default value is false.
	*/
	
	public function new(linkageID:String="", transparent:Bool=false, animated:Bool=false, createUnique:Bool=false, precise:Bool=false)
	{
		movieTransparent=transparent;
		this.animated=animated;
		this.createUnique=createUnique;
		this.precise=precise;
		if(linkageID.length>0)texture=linkageID;
	}


	// ______________________________________________________________________ CREATE BITMAP
	
	/*
	* since we need to pass a movieclip reference to MovieMaterial, I changed this method
	* from createBitmap, to createMovie.  the super's constructor will take care of
	* creating the actual bitmap reference
	*  
	*/
	private function createMovie(asset:Dynamic):MovieClip
	{
		// Remove previous bitmap
		if(this._texture !=asset)
		{
			_count[this._texture]--;

			var prevMovie:MovieClip=_library[this._texture];

			if(prevMovie && _count[this._texture]==0)
			{
				_library[this._texture]=null;
			}
		}
		
		// Retrieve from library or...
		var movie:MovieClip=_library[asset];
		
		var MovieAsset:Class;
		
		// ...attachMovie
		if(! movie)
		{
			MovieAsset=getDefinitionByName(asset)as Class;
			movie=new MovieAsset();
			_library[asset]=movie;
			_count[asset]=0;
		}
		else if(createUnique)
		{
			MovieAsset=getDefinitionByName(asset)as Class;
			movie=new MovieAsset();
		}
		else
		{
			_count[asset]++;
		}

		// Create Bitmap
		return  movie;
	}
	
}