/**
* ...
* @author Default
* @version 0.1
*/

package org.papervision3d.core.effects {

import flash.filters.BitmapFilter;

import org.papervision3d.view.layer.BitmapEffectLayer;

class AbstractEffect implements IEffect{

	function new(){}
	
	public function attachEffect(layer:BitmapEffectLayer):Void{}
	public function preRender():Void{}
	public function postRender():Void{}
	public function getEffect():BitmapFilter{
		return null;
	}
	
}