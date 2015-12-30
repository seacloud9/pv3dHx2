package org.papervision3d.materials.special;

import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.geom.Matrix;
import flash.geom.Rectangle;

import org.papervision3d.core.log.PaperLogger;

/**
 * Used to store the bitmap for a particle material. It also stores scale and offsets for moving the registration point of the bitmap. 
 * 
 * @author Seb Lee-Delisle
  	 */
  	 
class ParticleBitmap
{
	public var offsetX:Float;
	public var offsetY:Float;
	public var scaleX:Float;
	public var scaleY:Float;
	public var bitmap:BitmapData;
	public var width:Int;
	public var height:Int;

	
	//temporary matrix for drawing the bitmaps Into
	private static var drawMatrix:Matrix=new Matrix();
	private static var tempSprite:Sprite=new Sprite();
	
	
	public function new(source:Dynamic=null, scale:Float=1, forceMipMap:Bool=false, transparent:Bool=true)
	{
		offsetX=0;
		offsetY=0;
		scaleX=scale;
		scaleY=scale;
		if(Std.is(source, BitmapData))
		{
			bitmap=cast(source, BitmapData);
			width=bitmap.width;
			height=bitmap.height;
		} 
		else if(Std.is(source, DisplayObject))
		{
			create(source as DisplayObject, scale, transparent);
		}
	}
	
	public function create(clip:DisplayObject, scale:Float=1, transparent:Bool=true):BitmapData
	{
		var bounds:Rectangle=clip.getBounds(clip);
		
		//expand the bounds rectangle by the scale amount and snap them to pixels
		if(scale!=1)
		{
			// is there a faster way to do floor / ceil that works equally with negative and positive numbers?
			bounds.left=Math.floor(bounds.left*scale);
			bounds.right=Math.ceil(bounds.right*scale);
			bounds.top=Math.floor(bounds.top*scale);
			bounds.bottom=Math.ceil(bounds.bottom*scale);
			scaleX=scaleY=1/scale;
		}
		else
		{
			scaleX=scaleY=1;
		}
			
		width=bounds.width;
		height=bounds.height;
		
		offsetX=(bounds.left/scale);
		offsetY=(bounds.top/scale);

		drawMatrix.identity();
		drawMatrix.translate(-offsetX, -offsetY);
		drawMatrix.scale(1/scaleX, 1/scaleY);
		
		width=(width==0)? 1:width;
		height=(height==0)? 1:height;
		
		var bitmapwidth:Int=roundUpToMipMap(width);
		var bitmapheight:Int=roundUpToMipMap(height);
		
		// if the size is too big then we need to use a smaller bitmap and change the scale factors
		
		if(bitmapwidth<width)scaleX=width/bitmapwidth;
		if(bitmapheight<height)scaleY=height/bitmapheight;
		
		
		// if we don't have a bitmap or the bitmap is too small then make a new one
		// TODO! Make a bitmap factory! 
		if((!bitmap)||(bitmap.width<bitmapwidth)||(bitmap.height<bitmapheight)||(bitmap.height>>1>=bitmapheight)||(bitmap.width>>1>=bitmapwidth))
		{
			bitmap=new BitmapData(bitmapwidth, bitmapheight, transparent, 0x00000000);//0x55ff0000);
		}
		// otherwise just clear the bitmap
		else 
		{
			bounds.x=0;
			bounds.y=0;
			bitmap.fillRect(bounds, 0x00000000);//0x550000ff);
		}
		
		bitmap.draw(clip, drawMatrix, null, null, null, true);
		
		return bitmap;
	}
	
	
	
	
	
	
	public function createExact(clip:DisplayObject, posX:Float=1, posY:Float=1, scaleX:Float=1, scaleY:Float=1,  rotation:Float=0):BitmapData
	{
		
		//drawMatrix.identity();
		//if(rotation!=0)drawMatrix.rotate(rotation);
		//if(scale!=1)drawMatrix.scale(size);
		this.scaleX=scaleX 
		this.scaleY=scaleY;
		
		if(clip.parent)
			PaperLogger.warning("ParticleBitmap.createExact - particle movie shouldn't be a child of anything else ");
		
		//clip.transform.matrix=drawMatrix;
		
		tempSprite.addChild(clip);
		clip.x=posX;
		clip.y=posY;
		clip.rotation=rotation;
		clip.scaleX=scaleX;
		clip.scaleY=scaleY;
		
		var bounds:Rectangle=clip.getBounds(tempSprite);
		tempSprite.removeChild(clip);
		
		//expand the bounds rectangle by the scale amount and snap them to pixels
		
		// is there a faster way to do floor / ceil that works equally with negative and positive numbers?
		bounds.left=Math.floor(bounds.left);
		bounds.right=Math.ceil(bounds.right);
		bounds.top=Math.floor(bounds.top);
		bounds.bottom=Math.ceil(bounds.bottom);

		width=bounds.width;
		height=bounds.height;
				
		offsetX=(bounds.left/scaleX);
		offsetY=(bounds.top/scaleY);

		drawMatrix.identity();
		drawMatrix.translate(-offsetX, -offsetY);
		drawMatrix.scale(1/scaleX, 1/scaleY);
		
		width=(width==0)? 1:width;
		height=(height==0)? 1:height;
		
		if((!bitmap)||(bitmap.width<width)||(bitmap.height<height))
		{
			bitmap=new BitmapData(width, height, true, 0x00000000);
			
		}
		else 
		{
			bitmap.fillRect(bitmap.rect, 0x00000000);
		}
		bitmap.draw(clip, drawMatrix, null, null, null, true);
		
		return bitmap;
	}
	
	
	
	/** 
	 * rounds up to the nearest MIPMAP-able size to the value you pass in. 
	 * 
	 * Kudos to Jack Lang for writing this optimised function. 
	 * 
	 * 
	 * */
	private function roundUpToMipMap(val:Float):Int
	{
		
		var r:Int=Math.ceil(val);
		
		var i:Int=0;
		
		var ret:Int;
		
		var done:Bool=false;
		
		if(r==0 || r==1)
		{
			done=true;
			
			ret=r;
		}
		
		while(!done)
		{
			// if the number is binary 10 then round down
			if((r==2)||(r==3))
			{
				done=true;
				// round up
				ret=Math.pow(2, i + 2);
			}
			else
			{
				i++;
				
				r=r>>1;
				
				if(i>=10)
				{
					// at max, capping
					ret=2048;
					done=true;
				}
			}
		}
		
		return ret;
	
	}

	
	
	

	/** 
	 * Finds the nearest MIPMAP-able size to the value you pass in. 
	 * 
	 * Kudos to Jack Lang for writing this optimised function. 
	 * 
	 * 
	 * */
	private function getNearestMipMapSize(val:Float):Int
	{
		
		var r:Int=Math.ceil(val);
		
		var i:Int=0;
		
		var ret:Int;
		
		var done:Bool=false;
		
		if(r==0 || r==1)
		{
			done=true;
			
			ret=r;
		}
		
		while(!done)
		{
			// if the number is binary 10 then round down
			if(r==2)
			{
				done=true;
				// round down
				ret=Math.pow(2, i + 1);
			}
			
			// otherwise the number is binary 11 so round up
			else if(r==3)
			{
				done=true;
				// round up
				ret=Math.pow(2, i + 2);
			}
			else
			{
				i++;
				
				r=r>>1;
				
				if(i>=10)
				{
					// at max, capping
					ret=2048;
					done=true;
				}
			}
		}
		
		return ret;
	
	}
}