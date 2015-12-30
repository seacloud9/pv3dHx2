/*
 * Copyright 2007(c)Tim Knip, ascollada.org.
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files(the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */
 
package org.ascollada.core 
{
import flash.display.Bitmap;	
import flash.display.LoaderInfo;	
import flash.net.URLRequest;	
import flash.events.IOErrorEvent;	
import flash.events.Event;	
import flash.display.Loader;	

import org.ascollada.ASCollada;
import org.ascollada.fx.DaeEffect;
import org.ascollada.fx.DaeMaterial;
import org.ascollada.namespaces.*;
import org.ascollada.physics.DaePhysicsScene;
import org.ascollada.utils.Logger;
import org.ascollada.types.DaeAddressSyntax;	

/**
 * 
 */
class DaeDocument extends DaeEntity
{
//	#use namespace collada;
using away3d.namespace.Collada;
	
	public static inline var X_UP:Int=0;
	public static inline var Y_UP:Int=1;
	public static inline var Z_UP:Int=2;
	
	public var COLLADA:XML;

	public var version:String;
	
	public var sources:Dynamic;
	public var animation_clips:Dynamic;
	public var animations:Dynamic;
	public var animatables:Dynamic;
	public var controllers:Dynamic;
	public var effects:Dynamic;
	public var images:Dynamic;
	public var materials:Dynamic;
	public var geometries:Dynamic;
	public var physics_scenes:Dynamic;
	public var visual_scenes:Dynamic;
	public var nodes:Dynamic;
	public var cameras:Dynamic;
	
	public var vscene:DaeVisualScene;
	public var pscene:DaePhysicsScene;
	
	public var yUp:Int;
	
	public var materialSymbolToTarget:Dynamic;
	public var materialTargetToSymbol:Dynamic;
	
	public var numSources:Int=0;
	public var baseUrl:String;
	
	private var _waitingSources:Array<Dynamic>;
	private var _queuedImages:Array<Dynamic>;
	private var _fileSearchPaths:Array<Dynamic>;
	
	/**
	 * 
	 */
	public function new(object:Dynamic, async:Bool=false)
	{			
		this.COLLADA=object is XML ? object as XML:new XML(object);
		
		XML.ignoreWhitespace=true;
		
		_fileSearchPaths=new Array();
		_fileSearchPaths.push(".");
		
		super(this, this.COLLADA, async);
	}
	
	/**
	 * 
	 * @return
	 */
	private function buildMaterialTable():Void
	{
		materialSymbolToTarget=new Dynamic();
		materialTargetToSymbol=new Dynamic();
					
		var nodes:XMLList=this.COLLADA..collada::instance_material;
		
		for(var child:XML in nodes)
		{
			var target:String=getAttribute(child, ASCollada.DAE_TARGET_ATTRIBUTE);
			var symbol:String=getAttribute(child, ASCollada.DAE_SYMBOL_ATTRIBUTE);
			
			materialSymbolToTarget[symbol]=target;
			materialTargetToSymbol[target]=symbol;
		}
	}
	
	/**
	 * 
	 * @param	id
	 * @return
	 */
	private function findDaeNodeById(node:DaeNode, id:String, useSID:Bool=false):DaeNode
	{
		if(useSID)
		{
			if(node.sid==id)
				return node;
		}
		else
		{
			if(node.id==id)
				return node;
		}
		
		for(i in 0...node.nodes.length)
		{
			var n:DaeNode=findDaeNodeById(node.nodes[i], id, useSID);
			if(n)
				return n;
		}
		
		return null;
	}
	
	/**
	 * 
	 */
	public function addFileSearchPath(path:String):Void
	{
		if(_fileSearchPaths.indexOf(path)==-1)
		{
			if(path.charAt(path.length-1)=="/")
			{
				path=path.substr(0, path.length-1);
			}
			_fileSearchPaths.unshift(path);		
		}
	}
	
	/**
	 * 
	 * @param	id
	 * @return
	 */
	public function getDaeNodeById(id:String, useSID:Bool=false):DaeNode
	{
		for(var nod:DaeNode in this.nodes)
		{
			var nn:DaeNode=findDaeNodeById(nod, id, useSID);
			if(nn)
				return nn;
		}
		
		for(i in 0...this.vscene.nodes.length)
		{				
			var node:DaeNode=this.vscene.nodes[i];
			
			var n:DaeNode=findDaeNodeById(node, id, useSID);
			
			if(n)
			{
				//Logger.log("found '" + id + "' " + useSID + " ID:" + n.id + " Name:" + n.name + " SID:" + n.sid);
		
				return n;
			}
		}
		
		return null;
	}
	
	/**
	 * 
	 * @param	id
	 * @return
	 */
	public function getDaeNodeByIdOrSID(id:String):DaeNode
	{
		var node:DaeNode=getDaeNodeById(id, false);
		if(!node)
			node=getDaeNodeById(id, true);
		return node;
	}
	
	/**
	 * 
	 */
	public function getDaeChannelsForID(id:String):Array
	{
		var channels:Array<Dynamic>=new Array();
		var animation:DaeAnimation;
		for(animation in this.animations)
		{
			if(!animation.channels || !animation.channels.length)
			{
				continue;
			}
			
			for(var channel:DaeChannel in animation.channels)
			{
				if(id==channel.syntax.targetID)
				{
					channels.push(channel);
				}
			}
		}
		return channels;
	}
	
	/**
	 * 
	 */
	private function findDaeInstanceGeometry(node:DaeNode, url:String):DaeInstanceGeometry
	{
		for(var geometry:DaeInstanceGeometry in node.geometries)
		{
			if(geometry.url==url)
				return geometry;
		}	
		
		for(var child:DaeNode in node.nodes)
		{
			var g:DaeInstanceGeometry=findDaeInstanceGeometry(child, url);
			if(g)
				return g;
		}
		
		return null;
	}
	
	/**
	 * 
	 */
	public function getDaeInstanceGeometry(url:String):DaeInstanceGeometry
	{
		for(var node:DaeNode in this.vscene.nodes)
		{
			var geometry:DaeInstanceGeometry=findDaeInstanceGeometry(node, url);
			if(geometry)
				return geometry;
		}
		return null;
	} 
	
	/**
	 * 
	 */
	public function readNextSource():Bool
	{
		if(_waitingSources.length)
		{
			var node:XML=_waitingSources.pop()as XML;
			var source:DaeSource=new DaeSource(this.document, node);
			
			this.sources[source.id]=source;
		}
		
	
		return(_waitingSources.length>0);
	}
	
	/**
	 * 
	 */
	public function readNextImage():Bool
	{
		if(_loadingImage==null && _queuedImages.length)
		{
			_loadingImage=_queuedImages.pop()as DaeImage;	
			
			loadImage();
		}
		else
		{
			dispatchEvent(new Event(Event.COMPLETE));
		}
		return(_loadingImage==null && _queuedImages.length>0);
	}
	
	private var _currentImagePath:Int=-1;
	private var _loadingImage:DaeImage;
	
	private function loadImage():Void
	{
		var loader:Loader=new Loader();

		loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onImageComplete);	
		loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onImageIOError);
		
		var path:String=_loadingImage.init_from;
		
		var imageUrl:String=_loadingImage.init_from;
		
		if(_currentImagePath<0)
		{
			path=imageUrl;
			if(this.baseUrl)
			{
				path=buildImagePath(this.baseUrl, imageUrl);
			}
		} 
		else
		{
			path=_currentImagePath<_fileSearchPaths.length ? _fileSearchPaths[_currentImagePath]:"";
			
			if(imageUrl.indexOf("/")!=-1)
			{
				imageUrl=imageUrl.split("/").pop()as String;	
			}
			
			path=path + "/" + imageUrl;
		}
		
		loader.load(new URLRequest(path));
	}

	private function onImageComplete(event:Event):Void
	{
		var loaderInfo:LoaderInfo=event.target as LoaderInfo;
		var bitmap:Bitmap=loaderInfo.content as Bitmap;
		
		if(bitmap)
		{
			_loadingImage.bitmapData=bitmap.bitmapData;
		}
		
		_currentImagePath=-1;
		_loadingImage=null;
		
		readNextImage();
	}
	
	private function onImageIOError(event:IOErrorEvent):Void
	{
		_currentImagePath++;
		if(_currentImagePath<_fileSearchPaths.length)
		{
			loadImage();
		}
		else
		{
			_currentImagePath=-1;
			_loadingImage=null;
			readNextImage();
		}
	}

	/**
	 * 
	 */
	override public function destroy():Void 
	{
		super.destroy();
		
		var element:DaeEntity;
		
		if(this.sources)
		{
			for(element in this.sources)
			{
				element.destroy();
			}
			this.sources=null;
		}
		
		if(this.images)
		{
			for(element in this.images)
			{
				element.destroy();
			}
			this.images=null;
		}
		this.COLLADA=null;
	}

	/**
	 * 
	 * @param	node
	 * @return
	 */
	override public function read(node:XML):Void
	{
		this.version=node.attribute(ASCollada.DAE_VERSION_ATTRIBUTE).toString();
		
		Logger.log("version:" + this.version);
		
		// required!
		this.asset=new DaeAsset(this, getNode(this.COLLADA, ASCollada.DAE_ASSET_ELEMENT));
		
		if(this.asset.contributors && this.asset.contributors[0].author)Logger.log("author:" + this.asset.contributors[0].author);
		Logger.log("created:" + this.asset.created);
		Logger.log("modified:" + this.asset.modified);
		Logger.log("y-up:" + this.asset.yUp);
		Logger.log("unit_meter:" + this.asset.unit_meter);
		Logger.log("unit_name:" + this.asset.unit_name);
		
		if(this.asset.yUp==ASCollada.DAE_Y_UP)
			this.yUp=Y_UP;
		else
			this.yUp=Z_UP;
		
		buildMaterialTable();
		
		readLibImages();
		readSources();
		/*
		readLibAnimationClips();
		readLibCameras();
		readLibControllers();
		readLibAnimations();
		readLibImages();
		readLibMaterials();
		readLibEffects();
		readLibGeometries(this.async);
		readLibNodes();
		readLibPhysicsScenes();
		readLibVisualScenes();
		
		readScene();
		 
		 */
	}

	/**
	 * 
	 */
	public function readAfterSources():Void 
	{
		readLibAnimationClips();
		readLibAnimations();
		readLibCameras();
		readLibControllers();
		readLibMaterials();
		readLibEffects();
		readLibGeometries();
		readLibNodes();
		readLibPhysicsScenes();
		readLibVisualScenes();
		
		readScene();		
	}
	
	/**
	 * 
	 * @param	node
	 * @return
	 */
	private function readLibAnimations():Void
	{
		this.animations=new Dynamic();
		this.animatables=new Dynamic();
		
		var library:XML=getNode(this.COLLADA, ASCollada.DAE_LIBRARY_ANIMATION_ELEMENT);
		if(library)
		{
			var list:XMLList=getNodeList(library, ASCollada.DAE_ANIMATION_ELEMENT);
			for(var item:XML in list)
			{
				var animation:DaeAnimation=new DaeAnimation(this, item);
				
				readAnimation(animation);
			}
		}
	}

	/**
	 * 
	 */
	private function readAnimation(animation:DaeAnimation):Void 
	{
		var child:DaeAnimation;

		if(animation.channels && animation.channels.length)
		{
			this.animations[ animation.id ]=animation;
		}
		
		for(child in animation.animations)
		{
			readAnimation(child);		
		}
	}
	
	/**
	 * 
	 * @param	node
	 * @return
	 */
	private function readLibAnimationClips():Void
	{
		this.animation_clips=new Dynamic();
		var library:XML=getNode(this.COLLADA, ASCollada.DAE_LIBRARY_ANIMATION_CLIP_ELEMENT);
		if(library)
		{
			var list:XMLList=getNodeList(library, ASCollada.DAE_ANIMCLIP_ELEMENT);
			for(var item:XML in list)
			{
				var ent:DaeAnimationClip=new DaeAnimationClip(this, item);
				this.animation_clips[ ent.id ]=ent;
			}
		}
	}
	
	/**
	 * 
	 * @param	node
	 * @return
	 */
	private function readLibCameras():Void
	{
		this.cameras=new Dynamic();
		var library:XML=getNode(this.COLLADA, ASCollada.DAE_LIBRARY_CAMERA_ELEMENT);
		if(library)
		{
			var list:XMLList=getNodeList(library, ASCollada.DAE_CAMERA_ELEMENT);
			for(var item:XML in list)
			{
				var ent:DaeCamera=new DaeCamera(this, item);
				this.cameras[ ent.id ]=ent;
			}
		}
	}
	
	/**
	 * 
	 * @param	node
	 * @return
	 */
	private function readLibControllers():Void
	{
		this.controllers=new Dynamic();
		var library:XML=getNode(this.COLLADA, ASCollada.DAE_LIBRARY_CONTROLLER_ELEMENT);
		if(library)
		{
			var list:XMLList=getNodeList(library, ASCollada.DAE_CONTROLLER_ELEMENT);
			for(var item:XML in list)
			{
				var ent:DaeController=new DaeController(this, item);
				this.controllers[ ent.id ]=ent;
			}
		}
	}
	
	/**
	 * 
	 * @param	node
	 * @return
	 */
	private function readLibEffects():Void
	{
		this.effects=new Dynamic();
		var library:XML=getNode(this.COLLADA, ASCollada.DAE_LIBRARY_EFFECT_ELEMENT);
		if(library)
		{
			var list:XMLList=getNodeList(library, ASCollada.DAE_EFFECT_ELEMENT);
			for(var item:XML in list)
			{
				var ent:DaeEffect=new DaeEffect(this, item);
				this.effects[ ent.id ]=ent;
			}
		}
	}
	
	/**
	 * 
	 * @param	async
	 * @return
	 */
	private function readLibGeometries():Void
	{
		this.geometries=new Dynamic();
		var library:XML=getNode(this.COLLADA, ASCollada.DAE_LIBRARY_GEOMETRY_ELEMENT);
		if(library)
		{
			var list:XMLList=getNodeList(library, ASCollada.DAE_GEOMETRY_ELEMENT);
			for(var item:XML in list)
			{
				var geometry:DaeGeometry=new DaeGeometry(this, item, false);
				
				this.geometries[ geometry.id ]=geometry;
				
				if(geometry.mesh)
				{
					
				}
			}
		}
	}
	
	/**
	 * 
	 * @param	node
	 * @return
	 */
	private function readLibImages():Void
	{
		this.images=new Dynamic();
		var library:XML=getNode(this.COLLADA, ASCollada.DAE_LIBRARY_IMAGE_ELEMENT);
		
		_queuedImages=new Array();
		
		if(library)
		{
			var list:XMLList=getNodeList(library, ASCollada.DAE_IMAGE_ELEMENT);
			for(var item:XML in list)
			{
				var image:DaeImage=new DaeImage(this, item);
				
				this.images[ image.id ]=image;
			
				_queuedImages.push(image);
			}
		}
	}
	
	/**
	 * 
	 * @param	node
	 * @return
	 */
	private function readLibMaterials():Void
	{
		this.materials=new Dynamic();
		var library:XML=getNode(this.COLLADA, ASCollada.DAE_LIBRARY_MATERIAL_ELEMENT);
		if(library)
		{
			var list:XMLList=getNodeList(library, ASCollada.DAE_MATERIAL_ELEMENT);
			for(var item:XML in list)
			{
				var ent:DaeMaterial=new DaeMaterial(this, item);
				this.materials[ ent.id ]=ent;
			}
		}
	}

	/**
	 * 
	 * @param	node
	 * @return
	 */
	private function readLibNodes():Void
	{
		this.nodes=new Dynamic();
		var library:XML=getNode(this.COLLADA, ASCollada.DAE_LIBRARY_NODE_ELEMENT);
		if(library)
		{
			var list:XMLList=getNodeList(library, ASCollada.DAE_NODE_ELEMENT);
			for(var item:XML in list)
			{
				var node:DaeNode=new DaeNode(this, item);
				this.nodes[ node.id ]=node;
			}
		}
	}
	
	/**
	 * 
	 * @param	node
	 * @return
	 */
	private function readLibPhysicsScenes():Void
	{
		this.physics_scenes=new Dynamic();
		var library:XML=getNode(this.COLLADA, ASCollada.DAE_LIBRARY_PSCENE_ELEMENT);
		if(library)
		{
			var list:XMLList=getNodeList(library, ASCollada.DAE_PHYSICS_SCENE_ELEMENT);
			for(var item:XML in list)
			{
				var ent:DaePhysicsScene=new DaePhysicsScene(this, item);
				this.physics_scenes[ ent.id ]=ent;
			}
		}
	}
	
	/**
	 * 
	 * @param	node
	 * @return
	 */
	private function readLibVisualScenes():Void
	{
		this.visual_scenes=new Dynamic();
		var library:XML=getNode(this.COLLADA, ASCollada.DAE_LIBRARY_VSCENE_ELEMENT);
		if(library)
		{
			var list:XMLList=getNodeList(library, ASCollada.DAE_VSCENE_ELEMENT);
			for(var item:XML in list)
			{
				var ent:DaeVisualScene=new DaeVisualScene(this, item, yUp);
				this.visual_scenes[ ent.id ]=ent;
				this.vscene=ent;
			}
		}
	}
	
	/**
	 * 
	 * @return
	 */
	private function readScene():Void
	{
		// try to find a valid scene...
		var sceneNode:XML=getNode(this.COLLADA, ASCollada.DAE_SCENE_ELEMENT);
		if(sceneNode)
		{
			var vsceneNode:XML=getNode(sceneNode, ASCollada.DAE_INSTANCE_VSCENE_ELEMENT);
			if(vsceneNode)
			{
				var vurl:String=getAttribute(vsceneNode, ASCollada.DAE_URL_ATTRIBUTE);
				if(this.visual_scenes[vurl] is DaeVisualScene)
				{
					Logger.log("found visual scene:" + vurl);
					
					this.vscene=this.visual_scenes[ vurl ];
					
					Logger.log(" ->frameRate:" + this.vscene.frameRate);
					Logger.log(" ->startTime:" + this.vscene.startTime);
					Logger.log(" ->endTime:" + this.vscene.endTime);
				}
			}
			
			var psceneNode:XML=getNode(sceneNode, ASCollada.DAE_INSTANCE_PHYSICS_SCENE_ELEMENT);
			if(psceneNode)
			{
				var purl:String=getAttribute(psceneNode, ASCollada.DAE_URL_ATTRIBUTE);
				if(this.physics_scenes[purl] is DaePhysicsScene)
				{
					Logger.log("found physics scene:" + purl);
					this.pscene=this.physics_scenes[ purl ];
				}
			}
		}
	}
	
	/**
	 * 
	 */
	private function readSources():Void
	{
		var list:XMLList=this.COLLADA..source.(hasOwnProperty("@id"));
		var element:XML;
		
		this.numSources=list.length();
		this.sources=new Dynamic();
		
		_waitingSources=new Array();

		for(element in list){
			if(this.async){
				_waitingSources.push(element);
			} else {
				var source:DaeSource=new DaeSource(this, element);
				this.sources[source.id]=source;
			}
		}
	}
	
	public var waitingSources(get_waitingSources, null):Array;
 	private function get_waitingSources():Array
	{
		return _waitingSources;
	}
	
	/**
	 *
	 * @return
	 */
	private function buildImagePath(meshFolderPath:String, imgPath:String):String
	{
		var baseParts:Array<Dynamic>=meshFolderPath.split("/");
		var imgParts:Array<Dynamic>=imgPath.split("/");
		
		while(baseParts[0]==".")
			baseParts.shift();
			
		while(imgParts[0]==".")
			imgParts.shift();
			
		while(imgParts[0]=="..")
		{
			imgParts.shift();
			baseParts.pop();
		}
					
		var imgUrl:String=baseParts.length>1 ? baseParts.join("/"):(baseParts.length?baseParts[0]:"");
					
		imgUrl=imgUrl !="" ? imgUrl + "/" + imgParts.join("/"):imgParts.join("/");
		
		return imgUrl;
	}
}