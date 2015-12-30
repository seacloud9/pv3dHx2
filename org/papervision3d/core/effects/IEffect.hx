/**
* ...
* @author Default
* @version 0.1
*/

package org.papervision3d.core.effects {
import flash.filters.BitmapFilter;

import org.papervision3d.view.layer.BitmapEffectLayer;

interface IEffect {
	
	function attachEffect(layer:BitmapEffectLayer):Void;
	function preRender():Void;
	function postRender():Void;
	function getEffect():BitmapFilter;
	
}