package org.papervision3d.objects.parsers;

import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.utils.ByteArray<Dynamic>;
import flash.utils.Endian;

import org.papervision3d.Papervision3D;
import org.papervision3d.core.geom.TriangleMesh3D;
import org.papervision3d.core.geom.renderables.Triangle3D;
import org.papervision3d.core.geom.renderables.Vertex3D;
import org.papervision3d.core.math.NumberUV;
import org.papervision3d.core.proto.MaterialObject3D;
import org.papervision3d.events.FileLoadEvent;
import org.papervision3d.materials.BitmapFileMaterial;
import org.papervision3d.materials.ColorMaterial;
import org.papervision3d.materials.utils.MaterialsList;
import org.papervision3d.objects.DisplayObject3D;

/**
 * 3DS File parser.
 * 
 * @author Tim Knip(based on Away3D's Max3DS class:http://away3d.com)
 */ 
class Max3DS extends DisplayObject3D
{
	/** */
	public var filename:String;
	
	/**
	 * Constuctor
	 * 
	 * @param	name
	 */ 
	public function new(name:String=null)
	{
		super(name);
		_textureExtensionReplacements=new Dynamic();
	}
	
	/**
	 * Load.
	 * 
	 * @param	asset
	 * @param	materials
	 * @param	textureDir
	 */ 
	public function load(asset:Dynamic, materials:MaterialsList=null, textureDir:String="./image/"):Void
	{
		this.materials=materials || new MaterialsList();
		
		_textureDir=textureDir || _textureDir;
		
		if(Std.is(asset, ByteArray))
		{
			this.filename="NoName.3ds";
			parse(ByteArray(asset));
		}
		else if(Std.is(asset, String))
		{
			this.filename=Std.string(asset);
			
			var loader:URLLoader=new URLLoader();
			
			loader.dataFormat=URLLoaderDataFormat.BINARY;
			loader.addEventListener(Event.COMPLETE, onFileLoadComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onFileLoadError);
			loader.load(new URLRequest(this.filename));
		}
		else
			throw new Dynamic("Need String or ByteArray!");
	}
	
	/**
	 * Replaces a texture extension with an alternative extension.
	 * 
	 * @param	originalExtension	For example "bmp", "gif", etc
	 * @param	preferredExtension	For example "png"
	 */ 
	public function replaceTextureExtension(originalExtension:String, preferredExtension:String="png"):Void
	{
		_textureExtensionReplacements[originalExtension]=preferredExtension;
	}
	
	/**
	 * Build a mesh
	 * 
	 * @param	meshData
	 */ 
	private function buildMesh(meshData:MeshData):Void
	{
		var i:Int;
		var mesh:TriangleMesh3D=new TriangleMesh3D(null, meshData.vertices, [], meshData.name);
		
		for(i=0;i<meshData.faces.length;i++)
		{
			var f:Array<Dynamic>=meshData.faces[i];
			
			var v0:Vertex3D=mesh.geometry.vertices[f[0]];
			var v1:Vertex3D=mesh.geometry.vertices[f[1]];
			var v2:Vertex3D=mesh.geometry.vertices[f[2]];
			
			var hasUV:Bool=(meshData.uvs.length==meshData.vertices.length);
			
			var t0:FloatUV=hasUV ? meshData.uvs[f[0]]:new FloatUV();
			var t1:FloatUV=hasUV ? meshData.uvs[f[1]]:new FloatUV();
			var t2:FloatUV=hasUV ? meshData.uvs[f[2]]:new FloatUV();
			
			if(Papervision3D.useRIGHTHANDED)
				mesh.geometry.faces.push(new Triangle3D(mesh, [v2, v1, v0], null, [t2, t1, t0]));
			else
				mesh.geometry.faces.push(new Triangle3D(mesh, [v0, v1, v2], null, [t0, t1, t2]));
		}
		
		for(i=0;i<meshData.materials.length;i++)
		{
			var mat:MaterialData=meshData.materials[i];
			var material:MaterialObject3D=this.materials.getMaterialByName(mat.name);
			
			// http://code.google.com/p/papervision3d/issues/detail?id=208
			// fix proposed by Andy Watt.
			if(!material)
			{
				material=MaterialObject3D.DEFAULT;
				this.materials.addMaterial(material, mat.name);
			}

			for(j in 0...mat.faces.length)
			{
				var faceIdx:Int=mat.faces[j];
				var tri:Triangle3D=mesh.geometry.faces[faceIdx];
				tri.material=material;
			}
		}
		
		mesh.geometry.ready=true;
		mesh.rotationX=Papervision3D.useDEGREES ? -90:-90 *(Math.PI/180);
		//mesh.rotationY=Papervision3D.useDEGREES ? 180:180 *(Math.PI/180);
		
		addChild(mesh);
	}
	
	/**
	 * 
	 * @param	event
	 */ 
	private function onFileLoadComplete(event:Event=null):Void
	{
		var loader:URLLoader=event.target as URLLoader;
	
		parse(ByteArray(loader.data));
	}
	
	/**
	 * 
	 * @param	event
	 */ 
	private function onFileLoadError(event:IOErrorEvent):Void
	{
		dispatchEvent(new FileLoadEvent(FileLoadEvent.LOAD_ERROR, this.filename));
	}
	
	/**
	 * Parse.
	 * 
	 * @param	data
	 */ 
	private function parse(data:ByteArray):Void
	{
		if(!data)
			throw new Dynamic("Invalid ByteArray!");
		
		_data=data;
		_data.endian=Endian.LITTLE_ENDIAN;
		_data.position=0;
		
		//first chunk is always the primary, so we simply read it and parse it
		var chunk:Chunk3ds=new Chunk3ds();
		readChunk(chunk);
		parse3DS(chunk);
		
		dispatchEvent(new FileLoadEvent(FileLoadEvent.LOAD_COMPLETE, this.filename));
	}
	
	/**
	 * Read the base 3DS object.
	 * 
	 * @param chunk
	 * 
	 */		
	private function parse3DS(chunk:Chunk3ds):Void
	{
		while(chunk.bytesRead<chunk.length)
		{
			var subChunk:Chunk3ds=new Chunk3ds();
			readChunk(subChunk);
			switch(subChunk.id)
			{
				case EDIT3DS:
					parseEdit3DS(subChunk);
					break;
				case KEYF3DS:
					skipChunk(subChunk);
					break;
				default:
					skipChunk(subChunk);
			}
			chunk.bytesRead +=subChunk.length;
		}
	}
	
	/**
	 * Read the Edit chunk
	 * 
	 * @param chunk
	 */
	private function parseEdit3DS(chunk:Chunk3ds):Void
	{
		while(chunk.bytesRead<chunk.length)
		{
			var subChunk:Chunk3ds=new Chunk3ds();
			readChunk(subChunk);
			switch(subChunk.id)
			{
				case MATERIAL:
					parseMaterial(subChunk);
					//skipChunk(subChunk);
					break;
				case MESH:
					var meshData:MeshData=new MeshData();
					meshData.name=readASCIIZString(_data);
					
					subChunk.bytesRead +=meshData.name.length + 1;
					
					meshData.vertices=new Array();
					meshData.faces=new Array();
					meshData.uvs=new Array();
					meshData.materials=new Array();
					
					parseMesh(subChunk, meshData);
					
					buildMesh(meshData);
					break;
				default:
					skipChunk(subChunk);
			}
			
			chunk.bytesRead +=subChunk.length;
		}
	}
	
	/**
	 * Read a material chunk.
	 * 
	 * @param	chunk
	 */ 
	private function parseMaterial(chunk:Chunk3ds):String
	{
		var ret:String=null;
		var mat:Dynamic=new Dynamic();
		var subChunk:Chunk3ds=new Chunk3ds();
		var colorChunk:Chunk3ds=new Chunk3ds();
			
		mat.textures=new Array();
		
		while(chunk.bytesRead<chunk.length)
		{				
			readChunk(subChunk);
			var p:Int=0;
			
			switch(subChunk.id)
			{
				case MAT_NAME:
					mat.name=readASCIIZString(_data);
					//trace(mat.name);
					subChunk.bytesRead=subChunk.length;
					break;
				case MAT_AMBIENT:
					p=_data.position;
					readChunk(colorChunk);
					mat.ambient=readColor(colorChunk);
					_data.position=p + colorChunk.length;
					//trace("ambient:"+mat.ambient.toString(16));
					break;
				case MAT_DIFFUSE:
					p=_data.position;
					readChunk(colorChunk);
					mat.diffuse=readColor(colorChunk);
					_data.position=p + colorChunk.length;
					//trace("diffuse:"+mat.diffuse.toString(16));
					break;
				case MAT_SPECULAR:
					p=_data.position;
					readChunk(colorChunk);
					mat.specular=readColor(colorChunk);
					_data.position=p + colorChunk.length;
					//trace("specular:"+mat.specular.toString(16));
					break;
				case MAT_TEXMAP:
					mat.textures.push(parseMaterial(subChunk));
					break;
				case MAT_TEXFLNM:
					ret=readASCIIZString(_data);
					subChunk.bytesRead=subChunk.length;
					break;
				default:
					skipChunk(subChunk);
			}
			chunk.bytesRead +=subChunk.length;
		}
		
		if(mat.name && !this.materials.getMaterialByName(mat.name))
		{
			if(mat.textures.length)
			{
				var bitmap:String=mat.textures[0].toLowerCase();
				
				for(ext in _textureExtensionReplacements)
				{
					if(bitmap.indexOf("."+ext)==-1)
						continue;
					var pattern:RegExp=new RegExp("\."+ext, "i");
					bitmap=bitmap.replace(pattern, "."+_textureExtensionReplacements[ext]);
				}
				
				this.materials.addMaterial(new BitmapFileMaterial(_textureDir+bitmap), mat.name);
			}
			else if(mat.diffuse)
			{
				this.materials.addMaterial(new ColorMaterial(mat.diffuse), mat.name);
			}
		}
		
		return ret;
	}
	
	private function parseMesh(chunk:Chunk3ds, meshData:MeshData):Void
	{
		while(chunk.bytesRead<chunk.length)
		{
			var subChunk:Chunk3ds=new Chunk3ds();
			readChunk(subChunk);
			switch(subChunk.id)
			{
				case MESH_OBJECT:
					parseMesh(subChunk, meshData);
					break;
				case MESH_VERTICES:
					meshData.vertices=readMeshVertices(subChunk);
					break;
				case MESH_FACES:
					meshData.faces=readMeshFaces(subChunk);
					parseMesh(subChunk, meshData);
					break;
				case MESH_MATER:
					readMeshMaterial(subChunk, meshData);
					break;
				case MESH_TEX_VERT:
					meshData.uvs=readMeshTexVert(subChunk);
					break;
				default:
					skipChunk(subChunk);
			}
			chunk.bytesRead +=subChunk.length;
		}
	}
	
	/**
	 * 
	 * @param	chunk
	 */  
	private function readMeshFaces(chunk:Chunk3ds):Array
	{
		var faces:Array<Dynamic>=new Array();
		var numFaces:Int=_data.readUnsignedShort();
		chunk.bytesRead +=2;
		
		for(i in 0...numFaces)
		{
			var v2:Int=_data.readUnsignedShort();
			var v1:Int=_data.readUnsignedShort();
			var v0:Int=_data.readUnsignedShort();
			var visible:Bool=(_data.readUnsignedShort()as Bool);
			chunk.bytesRead +=8;
			
			faces.push([v0, v1, v2]);
		}
		return faces;
	}
	
	/**
	 * Read the Mesh Material chunk
	 * 
	 * @param chunk
	 */
	private function readMeshMaterial(chunk:Chunk3ds, meshData:MeshData):Void
	{
		var material:MaterialData=new MaterialData();
		
		material.name=readASCIIZString(_data);
		material.faces=new Array();
		
		chunk.bytesRead +=material.name.length +1;
		
		var numFaces:Int=_data.readUnsignedShort();
		chunk.bytesRead +=2;
		for(i in 0...numFaces)
		{
			material.faces.push(_data.readUnsignedShort());
			chunk.bytesRead +=2;
		}
		
		meshData.materials.push(material);
	}
	
	/**
	 * 
	 * @param	chunk
	 *
	 * @return
	 */ 
	private function readMeshTexVert(chunk:Chunk3ds):Array
	{
		var uvs:Array<Dynamic>=new Array();
		var numUVs:Int=_data.readUnsignedShort();
		chunk.bytesRead +=2;
		
		for(i in 0...numUVs)
		{
			uvs.push(new FloatUV(_data.readFloat(), _data.readFloat()));
			chunk.bytesRead +=8;
		}
		return uvs;
	}
	
	/**
	 * 
	 * @param	chunk
	 */ 
	private function readMeshVertices(chunk:Chunk3ds):Array
	{
		var vertices:Array<Dynamic>=new Array();
		var numVerts:Int=_data.readUnsignedShort();
		chunk.bytesRead +=2;
		
		for(i in 0...numVerts)
		{
			vertices.push(new Vertex3D(_data.readFloat(), _data.readFloat(), _data.readFloat()));
			chunk.bytesRead +=12;
		}
		
		return vertices;
	}
	
	/**
	 * Reads a null-terminated ascii string out of a byte array.
	 * 
	 * @param data The byte array to read from.
	 * 
	 * @return The string read, without the null-terminating character.
	 */		
	private function readASCIIZString(data:ByteArray):String
	{
		var readLength:Int=0;// length of string to read
		var l:Int=data.length - data.position;
		var tempByteArray:ByteArray<Dynamic>=new ByteArray();
		
		for(i in 0...l)
		{
			var c:Int=data.readByte();
			
			if(c==0)
			{
				break;
			}
			tempByteArray.writeByte(c);
		}
		
		var asciiz:String="";
		tempByteArray.position=0;
		for(i=0;i<tempByteArray.length;i++)
		{
			asciiz +=String.fromCharCode(tempByteArray.readByte());
		}
		return asciiz;
	}
	
	/**
	 * 
	 */ 
	private function readColor(colorChunk:Chunk3ds):Int
	{
		var color:Int=0;
		switch(colorChunk.id)
		{
			case COLOR_RGB:
				color=readColorRGB(colorChunk);
				break;
			case COLOR_F:
				color=readColorScale(colorChunk);
				break;
			default:
				throw new Dynamic("Unknown color chunk:" + colorChunk.id);
		}
		return color;
	}
	
	/**
	 * Read Scaled Color
	 * 
	 * @param	chunk
	 */ 
	private function readColorScale(chunk:Chunk3ds):Int
	{
		var color:Int=0;

		for(i in 0...3)
		{
			var c:Float=_data.readFloat();
			var bv:Int=255 * c;
			bv<<=(8 *(2 - i));
			color |=bv;													 
			chunk.bytesRead +=4;
		}
		
		return color;
	}
	
	/**
	 * Read RGB
	 * 
	 * @param	chunk
	 */ 
	private function readColorRGB(chunk:Chunk3ds):Int
	{
		var color:Int=0;
		
		for(i in 0...3)
		{
			var c:Int=_data.readUnsignedByte();
			color +=c*Math.pow(0x100, 2-i);
			chunk.bytesRead++;
		}
		
		return color;
	}
	
	/**
	 * Read id and length of 3ds chunk
	 * 
	 * @param chunk
	 */		
	private function readChunk(chunk:Chunk3ds):Void
	{
		chunk.id=_data.readUnsignedShort();
		chunk.length=_data.readUnsignedInt();
		chunk.bytesRead=6;
	}
	
	/**
	 * Skips past a chunk. If we don't understand the meaning of a chunk id,
	 * we just skip past it.
	 * 
	 * @param chunk
	 */		
	private function skipChunk(chunk:Chunk3ds):Void
	{
		_data.position +=chunk.length - chunk.bytesRead;
		chunk.bytesRead=chunk.length;
	}
	
	//>----- Color Types --------------------------------------------------------
	
	public static inline var AMBIENT:String="ambient";
	public static inline var DIFFUSE:String="diffuse";
	public static inline var SPECULAR:String="specular";
	
	//>----- Main Chunks --------------------------------------------------------
	
	public static inline var PRIMARY:Int=0x4D4D;
	public static inline var EDIT3DS:Int=0x3D3D;// Start of our actual objects
	public static inline var KEYF3DS:Int=0xB000;// Start of the keyframe information
	
	//>----- General Chunks -----------------------------------------------------
	
	public static inline var VERSION:Int=0x0002;
	public static inline var MESH_VERSION:Int=0x3D3E;
	public static inline var KFVERSION:Int=0x0005;
	public static inline var COLOR_F:Int=0x0010;
	public static inline var COLOR_RGB:Int=0x0011;
	public static inline var LIN_COLOR_24:Int=0x0012;
	public static inline var LIN_COLOR_F:Int=0x0013;
	public static inline var INT_PERCENTAGE:Int=0x0030;
	public static inline var FLOAT_PERC:Int=0x0031;
	public static inline var MASTER_SCALE:Int=0x0100;
	public static inline var IMAGE_FILE:Int=0x1100;
	public static inline var AMBIENT_LIGHT:Int=0X2100;
	
	//>----- Dynamic Chunks -----------------------------------------------------
	
	public static inline var MESH:Int=0x4000;
	public static inline var MESH_OBJECT:Int=0x4100;
	public static inline var MESH_VERTICES:Int=0x4110;
	public static inline var VERTEX_FLAGS:Int=0x4111;
	public static inline var MESH_FACES:Int=0x4120;
	public static inline var MESH_MATER:Int=0x4130;
	public static inline var MESH_TEX_VERT:Int=0x4140;
	public static inline var MESH_XFMATRIX:Int=0x4160;
	public static inline var MESH_COLOR_IND:Int=0x4165;
	public static inline var MESH_TEX_INFO:Int=0x4170;
	public static inline var HEIRARCHY:Int=0x4F00;
	
	//>----- Material Chunks ---------------------------------------------------
	
	public static inline var MATERIAL:Int=0xAFFF;
	public static inline var MAT_NAME:Int=0xA000;
	public static inline var MAT_AMBIENT:Int=0xA010;
	public static inline var MAT_DIFFUSE:Int=0xA020;
	public static inline var MAT_SPECULAR:Int=0xA030;
	public static inline var MAT_SHININESS:Int=0xA040;
	public static inline var MAT_FALLOFF:Int=0xA052;
	public static inline var MAT_EMISSIVE:Int=0xA080;
	public static inline var MAT_SHADER:Int=0xA100;
	public static inline var MAT_TEXMAP:Int=0xA200;
	public static inline var MAT_TEXFLNM:Int=0xA300;
	public static inline var OBJ_LIGHT:Int=0x4600;
	public static inline var OBJ_CAMERA:Int=0x4700;
	
	//>----- KeyFrames Chunks --------------------------------------------------
	
	public static inline var ANIM_HEADER:Int=0xB00A;
	public static inline var ANIM_OBJ:Int=0xB002;
	public static inline var ANIM_NAME:Int=0xB010;
	public static inline var ANIM_POS:Int=0xB020;
	public static inline var ANIM_ROT:Int=0xB021;
	public static inline var ANIM_SCALE:Int=0xB022;

	private var _data		:ByteArray<Dynamic>;
	
	private var _textureDir	:String="./image/";
	private var _textureExtensionReplacements:Dynamic;
}
}

class Chunk3ds
{	
public var id:Int;
public var length:Int;
public var bytesRead:Int;	 
}

class MeshData
{
public var name:String;
public var vertices:Array<Dynamic>;
public var faces:Array<Dynamic>;
public var uvs:Array<Dynamic>;
public var materials:Array<Dynamic>;
}

class MaterialData
{
public var name:String;
public var faces:Array<Dynamic>;
}
