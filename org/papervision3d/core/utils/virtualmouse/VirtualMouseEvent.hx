/**
* @author Trevor McCauley
* @link www.senocular.com
*/
package org.papervision3d.core.utils.virtualmouse;

import flash.events.Event;

/**
 * Wrapper for the Event class to let you check to
 * see if an event originated from the user's mouse
 * or a VirtualMouse instance.
 */
class VirtualMouseEvent extends Event implements IVirtualMouseEvent {
	public function new(type:String, bubbles:Bool=false, cancelable:Bool=false){
		super(type, bubbles, cancelable);
	}
}