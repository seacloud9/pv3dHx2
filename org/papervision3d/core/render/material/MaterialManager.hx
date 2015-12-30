package org.papervision3d.core.render.material;

import flash.utils.Dictionary;

import org.papervision3d.core.proto.MaterialObject3D;
import org.papervision3d.core.render.data.RenderSessionData;

/**
 * @Author Ralph Hauwert
 * 
 *<code>MaterialManager</code>(used Internally)is a singleton that tracks 
 * all materials. Each time a material is created, the<code>MaterialManager</code>
 * registers the material for access in the render engine. 
 */
class MaterialManager
{
	private static var instance:MaterialManager;
	private var materials:Dictionary;

	/**
	 * MaterialManager singleton constructor
	 */
	public function new():Void
	{
		if(instance){
			throw new Dynamic("Only 1 instance of materialmanager allowed");
		}
		init();
	}
	
	/** @private */
	private function init():Void
	{
		materials=new Dictionary(true);
	}
	
	/** @private */
	private function _registerMaterial(material:MaterialObject3D):Void
	{
		materials[material]=true;
	
	}
	
	/** @private */
	private function _unRegisterMaterial(material:MaterialObject3D):Void
	{
		delete materials[material];
	}
	
	/**
	 * Allows for materials that animate or change(e.g., MovieMaterial)to 
	 * be updated prior to the render
	 * 
	 * @param renderSessionData		the data used in updating the material
	 */
	public function updateMaterialsBeforeRender(renderSessionData:RenderSessionData):Void
	{
		var um:IUpdateBeforeMaterial;
					
		for(m in materials){
			if(Std.is(m, IUpdateBeforeMaterial)){
				um=cast(m, IUpdateBeforeMaterial);
				if(um.isUpdateable())
					um.updateBeforeRender(renderSessionData);
			}
		}
	}
	
	/**
	 * Allows for materials that animate or change(e.g., MovieMaterial)to 
	 * be updated after the render
	 * 
	 * @param renderSessionData		the data used in updating the material
	 */
	public function updateMaterialsAfterRender(renderSessionData:RenderSessionData):Void
	{
		var um:IUpdateAfterMaterial;
		
		for(m in materials){
			if(Std.is(m, IUpdateAfterMaterial)){
				um=cast(m, IUpdateAfterMaterial);
				um.updateAfterRender(renderSessionData);
			}
		}
	}
	
	/**
	 * Registers a material
	 */
	public static function registerMaterial(material:MaterialObject3D):Void
	{
		getInstance()._registerMaterial(material);
	}
	
	/**
	 * Unregisters a material
	 */
	public static function unRegisterMaterial(material:MaterialObject3D):Void
	{
		getInstance()._unRegisterMaterial(material);
	}
	
	/**
	 * Returns a singleton instance of the<code>MaterialManager</code>
	 */
	public static function getInstance():MaterialManager
	{
		if(!instance){
			instance=new MaterialManager;
		}
		return instance;
	}
	
}