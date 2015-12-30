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
import org.ascollada.core.DaeEntity;	

/**
 * 
 */
class DaeAccessor extends DaeEntity
{
	/** count - required */
	public var count:Int;
	
	/** source - required */
	public var source:String;
	
	/** offset - optional - default 0 */
	public var offset:Int;
	
	/** stride - optional - default 1 */
	public var stride:Int;
	
	/** params - optional - 0 or more */
	public var params:Dynamic;
			
	/**
	 * 
	 * @param	node
	 * @return
	 */
	public function new(document:DaeDocument, node:XML=null):Void
	{
		super(document, node);
	}	
	
	/**
	 * 
	 * @param	node
	 * @return
	 */
	override public function read(node:XML):Void
	{			
		if(node.localName()!=ASCollada.DAE_ACCESSOR_ELEMENT)
			throw new Dynamic("expected a " + ASCollada.DAE_ACCESSOR_ELEMENT + " element");
			
		super.read(node);
		
		this.count=getAttributeAsInt(node, ASCollada.DAE_COUNT_ATTRIBUTE);
		this.offset=getAttributeAsInt(node, ASCollada.DAE_OFFSET_ATTRIBUTE);
		this.source=getAttribute(node, ASCollada.DAE_SOURCE_ATTRIBUTE);
		this.stride=getAttributeAsInt(node, ASCollada.DAE_STRIDE_ATTRIBUTE, 1);
					
		var paramList:XMLList=getNodeList(node, ASCollada.DAE_PARAMETER);
	
		this.params=new Dynamic();
		
		// params
		for(var i:Int=0;i<paramList.length();i++)
		{
			var param:XML=paramList[i];
			var name:String=getAttribute(param, ASCollada.DAE_NAME_ATTRIBUTE);
			var type:String=getAttribute(param, ASCollada.DAE_TYPE_ATTRIBUTE);
			this.params[ name ]=type;
		}
	}
}