package org.papervision3d.objects.parsers {	import org.papervision3d.Papervision3D;	
	import flash.events.Event;
import flash.events.ProgressEvent;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.utils.ByteArray<Dynamic>;
import flash.utils.Endian;

import org.papervision3d.core.animation.IAnimatable;	
import org.papervision3d.core.animation.IAnimationProvider;
import org.papervision3d.core.animation.clip.AnimationClip3D;		import org.papervision3d.core.controller.IControllerProvider;	import org.papervision3d.core.controller.IObjectController;		import org.papervision3d.core.animation.key.LinearCurveKey3D;	
import org.papervision3d.core.animation.curve.Curve3D;	
import org.papervision3d.core.animation.channel.geometry.VerticesChannel3D;	
import org.papervision3d.core.animation.channel.Channel3D;	
import org.papervision3d.core.controller.AnimationController;	
import org.papervision3d.core.geom.TriangleMesh3D;
import org.papervision3d.core.geom.renderables.*;
import org.papervision3d.core.log.PaperLogger;
import org.papervision3d.core.math.NumberUV;
import org.papervision3d.core.proto.MaterialObject3D;
import org.papervision3d.core.render.data.RenderSessionData;
import org.papervision3d.events.FileLoadEvent;
import org.papervision3d.objects.DisplayObject3D;

/**
 * Loads Quake 2 MD2 file with animation!
 *</p>Please feel free to use, but please mention me!</p>
 * 
 * @author Philippe Ajoux(philippe.ajoux@gmail.com)adapted by Tim Knip(tim.knip at gmail.com).
 * @website www.d3s.net
 * @version 04.11.07:11:56
 */
class MD2 extends TriangleMesh3D implements IAnimatable, IAnimationProvider, IControllerProvider
{
	/**
	 * 
	 */
	private var _animation:AnimationController;
	
	/**
	 * 
	 */
	private var _controllers:Array<Dynamic>;
	
	/**
	 * Variables used in the loading of the file
	 */
	private var file:String;
	private var loader:URLLoader;
	private var loadScale:Float;
	
	/**
	 * MD2 Header data
	 * These are all the variables found in the md2_header_t
	 * C style struct that starts every MD2 file.
	 */
	private var ident:Int, version:Int;
	private var skinwidth:Int, skinheight:Int;
	private var framesize:Int;
	private var num_skins:Int, num_vertices:Int, num_st:Int;
	private var num_tris:Int, num_glcmds:Int, num_frames:Int;
	private var offset_skins:Int, offset_st:Int, offset_tris:Int;
	private var offset_frames:Int, offset_glcmds:Int, offset_end:Int;
	private var _fps:Int;
	private var _autoPlay:Bool;
	
	/**
	 * Constructor.
	 * 
	 * @param	autoPlay	Whether to start the _animation automatically.
	 */
	public function new(autoPlay:Bool=true):Void
	{
		super(null, new Array(), new Array());
		
		_autoPlay=autoPlay;
	}
	
	/**		 * Gets / sets the animation controller.		 * 		 * @see org.papervision3d.core.controller.AnimationController		 */		private function set_animation(value:AnimationController):Void		{			_animation=value;		}		
	public var animation(get_animation, set_animation):AnimationController;
 	private function get_animation():AnimationController
	{
		return _animation;
	}
			/**		 * Gets / sets all controlllers.		 * 		 * @return	Array of controllers.		 * 		 * @see org.papervision3d.core.controller.IObjectController		 * @see org.papervision3d.core.controller.AnimationController		 * @see org.papervision3d.core.controller.MorphController		 * @see org.papervision3d.core.controller.SkinController		 */		private function set_controllers(value:Array):Void		{			_controllers=value;		}				public var controllers(get_controllers, set_controllers):Array;
 	private function get_controllers():Array		{			return _controllers;			}		
	/**
	 * Pauses the animation.
	 */ 
	public function pause():Void
	{
		if(_animation)
		{
			_animation.pause();
		}
	}
	
	/**
	 * Plays the animation.
	 * 
	 * @param 	clip	Clip to play. Default is "all"
	 * @param 	loop	Whether the animation should loop. Default is true.
	 */ 
	public function play(clip:String="all", loop:Bool=true):Void
	{
		if(_animation)
		{
			_animation.play(clip, loop);
		}
	}
	
	/**
	 * Resumes a paused animation.
	 * 
	 * @param loop 	Whether the animation should loop. Defaults is true.
	 */ 
	public function resume(loop:Bool=true):Void
	{
		if(_animation)
		{
			_animation.resume(loop);
		}
	}
	
	/**
	 * Stops the animation.
	 */ 
	public function stop():Void
	{
		if(_animation)
		{
			_animation.stop();
		}
	}
	
	/**
	 * Whether the animation is playing. This property is read-only.
	 * 
	 * @return True when playing.
	 */
	public var playing(get_playing, null):Bool;
 	private function get_playing():Bool
	{
		return _animation ? _animation.playing:false;
	}
	
	/**
	 * Loads the MD2.
	 * 
	 * @param	asset	URL or ByteArray
	 * @param	material	The material for the MD2
	 * @param	fps		Frames per second
	 * @param	scale	Scale
	 */
	public function load(asset:Dynamic, material:MaterialObject3D=null, fps:Int=6, scale:Float=1):Void
	{
		this.loadScale=scale;
		this._fps=fps;
		this.visible=false;
		this.material=material || MaterialObject3D.DEFAULT;
		
		if(Std.is(asset, ByteArray))
		{
			this.file="";
			parse(asset as ByteArray);
		}
		else
		{
			this.file=Std.string(asset);
			
			loader=new URLLoader();
			loader.dataFormat=URLLoaderDataFormat.BINARY;
			loader.addEventListener(Event.COMPLETE, loadCompleteHandler);
			loader.addEventListener(ProgressEvent.PROGRESS, loadProgressHandler);
			
			try
			{
				loader.load(new URLRequest(this.file));
			}
			catch(e:Dynamic)
			{
				PaperLogger.error("error in loading MD2 file(" + this.file + ")");
			}
		}
	}
	
	/**
	 * Project.
	 * 
	 * @param	parent
	 * @param	renderSessionData
	 * 
	 * @return	Number
	 */ 
	public override function project(parent:DisplayObject3D, renderSessionData:RenderSessionData):Float
	{
		// update controllers			if(_controllers)			{
			for(var controller:IObjectController in _controllers)
			{
				controller.update();
			}
		}			
		return super.project(parent, renderSessionData);
	}
	
	/**
	 *<p>Parses the MD2 file. This is actually pretty straight forward.
	 * Only complicated parts(bit convoluded)are the frame loading
	 * and "metaface" loading. Hey, it works, use it=)</p>
	 * 
	 * @param	data	A ByteArray
	 */
	private function parse(data:ByteArray):Void
	{
		var i:Int, uvs:Array<Dynamic>=new Array();
		var metaface:Dynamic;
		
		_animation=new AnimationController();
		
		_controllers=new Array();
		_controllers.push(this._animation);
		
		data.endian=Endian.LITTLE_ENDIAN;
		
		// Read the header and make sure it is valid MD2 file
		readMd2Header(data);
		if(ident !=844121161 || version !=8)
			throw new Dynamic("error loading MD2 file(" + file + "):Not a valid MD2 file/bad version");
			
		//---Vertice setup
		// be sure to allocate memory for the vertices to the object
		for(i=0;i<num_vertices;i++)
			geometry.vertices.push(new Vertex3D());

		//---UV coordinates
		data.position=offset_st;
		for(i=0;i<num_st;i++)
		{
			var uv:FloatUV=new FloatUV(data.readShort()/ skinwidth, data.readShort()/ skinheight);
			//uv.u=1 - uv.u;
			uv.v=1 - uv.v;
			uvs.push(uv);
		}

		//---Frame _animation data
		data.position=offset_frames;
		readFrames(data);
		
		//---Faces
		// make sure to push the faces with allocated vertices to the object!
		data.position=offset_tris;
		for(i=0;i<num_tris;i++)
		{
			metaface={a:data.readUnsignedShort(), b:data.readUnsignedShort(), c:data.readUnsignedShort(),
						ta:data.readUnsignedShort(), tb:data.readUnsignedShort(), tc:data.readUnsignedShort()};
			
			var v0:Vertex3D=geometry.vertices[metaface["a"]];
			var v1:Vertex3D=geometry.vertices[metaface["b"]];
			var v2:Vertex3D=geometry.vertices[metaface["c"]];
			
			var uv0:FloatUV=uvs[metaface["ta"]];
			var uv1:FloatUV=uvs[metaface["tb"]];
			var uv2:FloatUV=uvs[metaface["tc"]];

			geometry.faces.push(new Triangle3D(this, [v2, v1, v0], material, [uv2, uv1, uv0]));
		}
		
		geometry.ready=true;

		visible=true;
					
		PaperLogger.info("Parsed MD2:" + file + "\n vertices:" + 
						  geometry.vertices.length + "\n texture vertices:" + uvs.length +
						  "\n faces:" + geometry.faces.length + "\n frames:" + num_frames);

		dispatchEvent(new FileLoadEvent(FileLoadEvent.LOAD_COMPLETE, this.file));
		dispatchEvent(new FileLoadEvent(FileLoadEvent.ANIMATIONS_COMPLETE, this.file));
		
		if(_autoPlay)
		{
			this._animation.play();
		}
	}
	
	/**
	 * Reads in all the frames
	 */
	private function readFrames(data:ByteArray):Void
	{
		var sx:Float, sy:Float, sz:Float;
		var tx:Float, ty:Float, tz:Float;
		var i:Int, j:Int, char:Int;
		var duration:Float=1 / _fps;
		
		var curves:Array<Dynamic>=new Array(num_vertices);
		var curName:String="all";
		var clip:AnimationClip3D;
		var clipPos:Int=0;
		
		for(i=0;i<num_frames;i++)
		{				
			sx=data.readFloat();
			sy=data.readFloat();
			sz=data.readFloat();
			
			tx=data.readFloat();
			ty=data.readFloat();
			tz=data.readFloat();
			
			var frameName:String="";
			
			for(j=0;j<16;j++)
				if((char=data.readUnsignedByte())!=0)
					frameName +=String.fromCharCode(char);
			
			var shortName:String=frameName.replace(/\d+/, "");
			
			if(curName !=shortName)
			{
				if(clip)
				{
					clip.endTime=(i-1)* duration;
					this._animation.addClip(clip);
				}
				
				clip=new AnimationClip3D(shortName, i * duration);
				curName=shortName;
				clipPos=0;
			}

			// Note, the extra data.position++ in the for loop is there 
			// to skip over a byte that holds the "vertex normal index"
			for(j=0;j<num_vertices;j++, data.position++)
			{
				var v:Vertex3D=new Vertex3D(
					((sx * data.readUnsignedByte())+ tx)* loadScale, 
					((sy * data.readUnsignedByte())+ ty)* loadScale,
					((sz * data.readUnsignedByte())+ tz)* loadScale);
				
				v.x=Papervision3D .useRIGHTHANDED  ? v.x:- v.x;
				
				if(!curves[j])
				{
					curves[j]=new Array(3);	
					curves[j][0]=new Curve3D();
					curves[j][1]=new Curve3D();
					curves[j][2]=new Curve3D();
				}
				
				curves[j][0].addKey(new LinearCurveKey3D(i * duration, v.x));
				curves[j][1].addKey(new LinearCurveKey3D(i * duration, v.y));
				curves[j][2].addKey(new LinearCurveKey3D(i * duration, v.z));
				
				if(i==1)
				{
					this.geometry.vertices[j].x=v.x;
					this.geometry.vertices[j].y=v.y;
					this.geometry.vertices[j].z=v.z;
				}
			}
			
			clipPos++;
		}

		var channel:VerticesChannel3D=new VerticesChannel3D(this.geometry);
		
		for(i=0;i<num_vertices;i++)
		{
			var update:Bool=(i==num_vertices - 1);
			
			channel.addCurve(curves[i][0], update);	
			channel.addCurve(curves[i][1], update);
			channel.addCurve(curves[i][2], update);
		}
		
		_animation.addChannel(channel);
		if(clip)
		{
			clip.endTime=_animation.endTime;
			_animation.addClip(clip);
		}
	}

	/**
	 * Reads in all that MD2 Header data that is declared as private variables.
	 * I know its a lot, and it looks ugly, but only way to do it in Flash
	 */
	private function readMd2Header(data:ByteArray):Void
	{
		ident=data.readInt();
		version=data.readInt();
		skinwidth=data.readInt();
		skinheight=data.readInt();
		framesize=data.readInt();
		num_skins=data.readInt();
		num_vertices=data.readInt();
		num_st=data.readInt();
		num_tris=data.readInt();
		num_glcmds=data.readInt();
		num_frames=data.readInt();
		offset_skins=data.readInt();
		offset_st=data.readInt();
		offset_tris=data.readInt();
		offset_frames=data.readInt();
		offset_glcmds=data.readInt();
		offset_end=data.readInt();
	}

	/**
	 * 
	 */ 
	private function loadCompleteHandler(event:Event):Void
	{
		var loader:URLLoader=event.target as URLLoader;
		var data:ByteArray<Dynamic>=loader.data;
		parse(data);
	}
	
	/**
	 * 
	 * @param	event
	 * @return
	 */
	private function loadProgressHandler(event:ProgressEvent):Void
	{
		dispatchEvent(event);
	}
}