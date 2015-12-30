/**
* @author Trevor McCauley
* @link www.senocular.com
*/
package org.papervision3d.core.utils.virtualmouse;

import flash.display.InteractiveObject;
import flash.events.MouseEvent;

/**
 * Wrapper for the MouseEvent class to let you check
 * to see if an event originated from the user's mouse
 * or a VirtualMouse instance.
 */
class VirtualMouseMouseEvent extends MouseEvent implements IVirtualMouseEvent {
	public function new(type:String, bubbles:Bool=false, cancelable:Bool=false, localX:Float=NaN, localY:Float=NaN, relatedObject:InteractiveObject=null, ctrlKey:Bool=false, altKey:Bool=false, shiftKey:Bool=false, buttonDown:Bool=false, delta:Int=0){
		super(type, bubbles, cancelable, localX, localY, relatedObject, ctrlKey, altKey, shiftKey, buttonDown, delta);
	}
}