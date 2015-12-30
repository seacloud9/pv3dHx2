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
 
package org.ascollada.core {

import flash.utils.Dictionary;

import org.ascollada.ASCollada;

class DaePrimitive extends DaeEntity {
	
	/** parent element */
	public var mesh:DaeMesh;
	
	/** The number of line primitives. required */
	public var count:Int;
	
	/** materialname */
	public var material:String;
					
	/** vcount use by polygon primitives */
	public var vcount:Array<Dynamic>;
	
	/** primitive type */
	public var type:String;
	
	public var polygons:Array<Dynamic>;
	
	/**
	 * 
	 * @param	mesh
	 * @param	node
	 * @return
	 */
	public function new(document:DaeDocument, mesh:DaeMesh, node:XML=null):Void {
		this.mesh=mesh;
		super(document, node);
	}
	
	/** normals */
	public var normals(get_normals, null):Array;
 	private function get_normals():Array { return getFirstInput("NORMAL");}
	
	/** vertex indices */
	public var vertices(get_vertices, null):Array;
 	private function get_vertices():Array { return getFirstInput("VERTEX");}
	
	/**
	 * gets the texcoords by set.
	 * 
	 * @param	setID
	 * @return
	 */
	public function getTexCoords(setID:Int=0):Array {
		return getInputBySet("TEXCOORD", setID);
	}
	
	/**
	 * 
	 * @return
	 */
	override public function read(node:XML):Void {
		
		if(!checkNode(node))
			throw new Dynamic("expected a primitive element!");
		if(!this.mesh)
			throw new Dynamic("parent-element 'mesh' or 'convex_mesh' not set!");
			
		super.read(node);
		
		this.type=Std.string(node.localName());
		
		this.count=getAttributeAsInt(node, ASCollada.DAE_COUNT_ATTRIBUTE);
		this.material=getAttribute(node, ASCollada.DAE_MATERIAL_ATTRIBUTE);
		this.vcount=new Array();
		this.polygons=new Array();
		
		if(this.count==0)
		{
			return;
		}
		
		_inputs=new Dictionary();
		
		var parent:XML=node.parent()as XML;
		
		switch(String(parent.localName())){
			case ASCollada.DAE_MESH_ELEMENT:
				switch(node.localName()as String)
				{
					case ASCollada.DAE_POLYGONS_ELEMENT:
						parsePolygons(node);
						break;
					default:
						parse(node);
						break;
				}
				break;
			case ASCollada.DAE_CONVEX_MESH_ELEMENT:
				break;
			default:
				break;
		}
	}
	
	/**
	 * 
	 * @param	node
	 * @return
	 */		
	private function parse(node:XML):Void {
		var p:Array<Dynamic>=getInts(getNode(node, ASCollada.DAE_POLYGON_ELEMENT));
		var vcountNode:XML=getNode(node, ASCollada.DAE_VERTEXCOUNT_ELEMENT);
		var inputList:XMLList=getNodeList(node, ASCollada.DAE_INPUT_ELEMENT);
		var inputs:Array<Dynamic>=new Array();
		var input:DaeInput;
		var maxoffset:Int=0;
		var source:DaeSource;
		
		if(Std.is(vcountNode, XML))
		{
			this.vcount=getInts(vcountNode);
		}
		for(var inputNode:XML in inputList){
			input=new DaeInput(this.document, inputNode);
			maxoffset=Math.max(maxoffset, input.offset + 1);
			inputs.push(input);
			
			_inputs[ input ]=new Array();
			
			if(this.mesh.vertices.id==input.source)
			{
				this.document.sources[input.source]=this.mesh.vertices.source;
			}
		}
		
		for(i in 0...p.length +=maxoffset){
			for(input in inputs){
				var idx:Int=p[i + input.offset];
				
				source=this.document.sources[ input.source ];
				
				var values:Array<Dynamic>=source.values;
				
				switch(input.semantic){
					case "VERTEX":
						_inputs[ input ].push(idx);
						break;
					case "NORMAL":
						break;
					default:
						_inputs[ input ].push(values[idx]);
						break;
				}
			}
		}
	}
	
	private function parsePolygons(node:XML):Void
	{
		var inputs:Array<Dynamic>=new Array();
		var input:DaeInput;
		var maxoffset:Int=0;
		var inputList:XMLList=getNodeList(node, ASCollada.DAE_INPUT_ELEMENT);
		var pList:XMLList=getNodeList(node, ASCollada.DAE_POLYGON_ELEMENT);
		var i:Int;
		
		for(i=0;i<inputList.length();i++)
		{
			input=new DaeInput(this.document, inputList[i]);

			maxoffset=Math.max(maxoffset, input.offset + 1);
			
			inputs.push(input);
			
			_inputs[ input ]=new Array();
			
			if(this.mesh.vertices.id==input.source)
			{
				this.document.sources[input.source]=this.mesh.vertices.source;
			}
		}
		
		for(var pNode:XML in pList)
		{
			var p:Array<Dynamic>=getInts(pNode);
			var poly:Array<Dynamic>=new Array();
			for(i=0;i<p.length;i +=maxoffset)
			{
				for(input in inputs)
				{
					var idx:Int=p[i + input.offset];
					var values:Array<Dynamic>=this.document.sources[input.source].values;
					
					switch(input.semantic){
						case "VERTEX":
							_inputs[ input ].push(idx);
							poly.push(idx);
							break;
						default:
							_inputs[ input ].push(values[idx]);
							break;
					}
				}				
			}
			this.polygons.push(poly);
		}
	}
	
	/**
	 * 
	 * @param	node
	 * @return
	 */
	private function checkNode(node:XML):Bool {
		var name:String=Std.string(node.localName());
		
		return(name==ASCollada.DAE_TRIANGLES_ELEMENT ||
				name==ASCollada.DAE_TRIFANS_ELEMENT ||
				name==ASCollada.DAE_TRISTRIPS_ELEMENT ||
				name==ASCollada.DAE_LINESTRIPS_ELEMENT ||
				name==ASCollada.DAE_LINES_ELEMENT ||
				name==ASCollada.DAE_POLYGONS_ELEMENT ||
				name==ASCollada.DAE_POLYLIST_ELEMENT);
	}

	/**
	 * 
	 * @param	semantic
	 * @return
	 */
	public function getFirstInput(semantic:String):Array
	{
		for(input in _inputs)
		{
			if(input["semantic"]==semantic)
				return _inputs[ input ];
		}
		return null;
	}
	
	/**
	 * 
	 * @param	semantic
	 * @return
	 */
	private function getInputBySet(semantic:String, setID:Int):Array
	{
		if(getInputCount(semantic)==1)
			return getFirstInput(semantic);
		for(input in _inputs){
			if(input["semantic"]==semantic && input["setId"]==setID)
				return _inputs[ input ];
		}
		return new Array();
	}
	
	/**
	 * 
	 * @param	semantic
	 * @return
	 */
	private function getInputCount(semantic:String):Int
	{
		var cnt:Int=0;
		for(input in _inputs)
		{
			if(input["semantic"]==semantic)
				cnt++;
		}
		return cnt;
	}
			
	private var _inputs:Dictionary;
}