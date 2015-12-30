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
 
package org.ascollada.core;

import org.ascollada.ASCollada;
import org.ascollada.core.DaeEntity;
import org.ascollada.utils.Logger;
	
/**
 * 
 */
class DaeMorph extends DaeEntity
{			
	public static inline var METHOD_NORMALIZED:String="NORMALIZED";
	public static inline var METHOD_RELATIVE:String="RELATIVE";
	
	public var source:String;
	
	public var targets:DaeSource;
	
	public var weights:DaeSource;
	
	public var method:String;
	
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
		if(node.localName()!=ASCollada.DAE_CONTROLLER_MORPH_ELEMENT)
			return;
			
		super.read(node);
				
		// required - ref to morph's geometry
		this.source=getAttribute(node, ASCollada.DAE_SOURCE_ATTRIBUTE);
		
		// defaults to METHOD_NORMALIZED
		this.method=getAttribute(node, ASCollada.DAE_METHOD_ATTRIBUTE)==METHOD_RELATIVE ? METHOD_RELATIVE:METHOD_NORMALIZED;
		
		Logger.log("reading morph, source:" + this.source + " method:" + this.method);
		
		// exactly one targets element
		var targetNode:XML=getNode(node, ASCollada.DAE_TARGETS_ELEMENT);
	
		this.targets=this.weights=null;
		
		var inputList:XMLList=getNodeList(targetNode, ASCollada.DAE_INPUT_ELEMENT);
		
		for(var inputNode:XML in inputList)
		{
			var input:DaeInput=new DaeInput(this.document, inputNode);
			
			switch(input.semantic)
			{
				case ASCollada.DAE_TARGET_MORPH_INPUT:
					this.targets=this.document.sources[ input.source ];
					break;
					
				case ASCollada.DAE_WEIGHT_MORPH_INPUT:
					this.weights=this.document.sources[ input.source ];
					break;
					
				default:
					break;
			}
		}
		
		if(!this.targets)
			throw new Dynamic("Invalid morph, could not find morph-targets");
		if(!this.weights)
			throw new Dynamic("Invalid morph, could not find morhp-weights!");
	}
}