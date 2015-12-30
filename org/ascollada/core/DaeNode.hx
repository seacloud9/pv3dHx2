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
import org.ascollada.ASCollada;
import org.ascollada.core.DaeDocument;
import org.ascollada.core.DaeEntity;
import org.ascollada.core.DaeInstanceController;
import org.ascollada.core.DaeInstanceGeometry;
import org.ascollada.types.DaeTransform;	

/**
 * 
 */
class DaeNode extends DaeEntity
{
	public static inline var TYPE_NODE:Int=0;
	public static inline var TYPE_JOINT:Int=1;
	
	/** node type, can be TYPE_NODE or TYPE_JOINT */
	public var type:Int;
	
	/** array of childnodes */
	public var nodes:Array<Dynamic>;
	
	/** */
	public var transforms:Array<Dynamic>;
	
	/** array of controller instances */
	public var controllers:Array<Dynamic>;
	
	/** array of geometry instances */
	public var geometries:Array<Dynamic>;
	
	/** array of instance_node instances */
	public var instance_nodes:Array<Dynamic>;
	
	/** array of instance_cameras */
	public var instance_cameras:Array<Dynamic>;
	
	/** */
	public var channels:Array<Dynamic>;
	
	/** */
	public var hasMorphController:Bool;
	
	/** */
	public var hasSkinController:Bool;
	
	private var _yUp:Int;
	
	/**
	 * 
	 * @param	node
	 * @return
	 */
	public function new(document:DaeDocument, node:XML=null, yUp:Int=1):Void
	{
		_yUp=yUp;
		
		super(document, node);
	}

	/**
	 * 
	 * @param	id
	 * @return
	 */
	public function findController(id:String):DaeInstanceController
	{
		for(var ctrl:DaeInstanceController in this.controllers)
		{
			if(id==ctrl.id)
				return ctrl;
		}
		return null;
	}
	
	/**
	 * 
	 * @param	sid
	 * @return
	 */
	public function findMatrixBySID(sid:String):DaeTransform
	{
		for(var transform:DaeTransform in this.transforms)
		{
			if(sid==transform.sid)
				return transform;
		}
		return null;
	}
	
	/**
	 * 
	 * @param	node
	 * @return
	 */
	override public function read(node:XML):Void
	{	
		this.nodes=new Array();
		this.controllers=new Array();
		this.geometries=new Array();
		this.instance_nodes=new Array();
		this.instance_cameras=new Array();
		this.transforms=new Array();
		this.hasMorphController=this.hasSkinController=false;
		
		if(node.localName()!=ASCollada.DAE_NODE_ELEMENT)
			throw new Dynamic("expected a '" + ASCollada.DAE_NODE_ELEMENT + "' element");
			
		super.read(node);
					
		this.name=this.name && this.name.length ? this.name:this.id;
				
		this.type=getAttribute(node, ASCollada.DAE_TYPE_ATTRIBUTE)=="JOINT" ? TYPE_JOINT:TYPE_NODE;

		//var yUp:Bool=(this._yUp==DaeDocument.Y_UP);
		var children:XMLList=node.children();
		var num:Int=children.length();
		
		for(i in 0...num)
		{
			var child:XML=children[i];
			var floats:Array<Dynamic>;
			var csid:String=getAttribute(child, ASCollada.DAE_SID_ATTRIBUTE);
			var transform:DaeTransform;
			
			switch(child.localName())
			{	
				case ASCollada.DAE_ASSET_ELEMENT:
					break;
					
				case ASCollada.DAE_ROTATE_ELEMENT:			
					floats=getFloats(child);
					transform=new DaeTransform(ASCollada.DAE_ROTATE_ELEMENT, csid, floats);
					this.transforms.push(transform);
					break;
					
				case ASCollada.DAE_TRANSLATE_ELEMENT:
					floats=getFloats(child);
					transform=new DaeTransform(ASCollada.DAE_TRANSLATE_ELEMENT, csid, floats);
					this.transforms.push(transform);
					break;
					
				case ASCollada.DAE_SCALE_ELEMENT:
					floats=getFloats(child);
					transform=new DaeTransform(ASCollada.DAE_SCALE_ELEMENT, csid, floats);
					this.transforms.push(transform);
					break;
					
				case ASCollada.DAE_SKEW_ELEMENT:
					floats=getFloats(child);
					break;
					
				case ASCollada.DAE_LOOKAT_ELEMENT:
					floats=getFloats(child);
					break;
					
				case ASCollada.DAE_MATRIX_ELEMENT:
					floats=getFloats(child);
					transform=new DaeTransform(ASCollada.DAE_MATRIX_ELEMENT, csid, floats);
					this.transforms.push(transform);
					break;
					
				case ASCollada.DAE_NODE_ELEMENT:
					this.nodes.push(new DaeNode(this.document, child, _yUp));
					break;
				
				case ASCollada.DAE_INSTANCE_CAMERA_ELEMENT:
					this.instance_cameras.push(getAttribute(child, ASCollada.DAE_URL_ATTRIBUTE));
					break;
					
				case ASCollada.DAE_INSTANCE_CONTROLLER_ELEMENT:
					this.controllers.push(new DaeInstanceController(this.document, child));
					break;
				
				case ASCollada.DAE_INSTANCE_GEOMETRY_ELEMENT:
					this.geometries.push(new DaeInstanceGeometry(this.document, child));
					break;
				
				case ASCollada.DAE_INSTANCE_LIGHT_ELEMENT:
					break;
					
				case ASCollada.DAE_INSTANCE_NODE_ELEMENT:
					this.instance_nodes.push(new DaeInstanceNode(this.document, child));
					break;
					
				case ASCollada.DAE_EXTRA_ELEMENT:
					break;
					
				default:
					break;
			}
		}
		
		for(var controllerInstance:DaeInstanceController in this.controllers)
		{
			var controller:DaeController=this.document.controllers[ controllerInstance.url ];
			if(controller && controller.morph)
			{
				this.hasMorphController=true;
			}
			else if(controller && controller.skin)
			{
				this.hasSkinController=true;	
			}
		}
	}
}