package org.ascollada.fx 
{
import org.ascollada.ASCollada;	
import org.ascollada.core.DaeDocument;	
import org.ascollada.core.DaeEntity;
import org.ascollada.namespaces.collada;

/**
 * @author Tim Knip / floorplanner.com
 */
class DaeBindMaterial extends DaeEntity 
{
//	#use namespace collada;
using away3d.namespace.Collada;
	
	/** */
	public var instanceMaterials:Array<Dynamic>;
	
	/**
	 * 
	 */
	public function new(document:DaeDocument, node:XML=null, async:Bool=false)
	{
		super(document, node, async);
	}

	/**
	 * 
	 */
	override public function destroy():Void 
	{
		super.destroy();
		
		var element:DaeInstanceMaterial;
		
		if(this.instanceMaterials)
		{
			for(element in this.instanceMaterials)
			{
				element.destroy();
			}
			this.instanceMaterials=null;
		}
	}

	/**
	 * 
	 */
	public function getInstanceMaterialBySymbol(symbol:String):DaeInstanceMaterial
	{
		if(this.instanceMaterials)
		{
			for(var instanceMaterial:DaeInstanceMaterial in this.instanceMaterials)
			{
				if(instanceMaterial.symbol==symbol)
				{
					return instanceMaterial;
				}
			}
		}
		return null;
	}

	/**
	 * 
	 */
	override public function read(node:XML):Void 
	{
		super.read(node);
		
		var list:XMLList=node..collada::[ASCollada.DAE_INSTANCE_MATERIAL_ELEMENT];
		var num:Int=list.length();
		var i:Int;
		
		this.instanceMaterials=new Array();
		
		for(i=0;i<num;i++)
		{
			this.instanceMaterials.push(new DaeInstanceMaterial(this.document, list[i]));
		}
	}
}