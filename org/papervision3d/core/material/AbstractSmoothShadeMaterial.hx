package org.papervision3d.core.material;

import flash.geom.Matrix;

import org.papervision3d.core.render.draw.ITriangleDrawer;
import org.papervision3d.core.render.material.IUpdateBeforeMaterial;

/**
 * @Author Ralph Hauwert
 */
class AbstractSmoothShadeMaterial extends AbstractLightShadeMaterial implements ITriangleDrawer, IUpdateBeforeMaterial
{
	private var transformMatrix:Matrix;
	private var triMatrix:Matrix;
	
	public function new()
	{
		super();
		
	}
	
	override private function init():Void
	{
		super.init();
		transformMatrix=new Matrix();
		triMatrix=new Matrix();
	}
	
}