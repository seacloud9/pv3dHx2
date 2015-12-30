package org.papervision3d.core.render.command;


/**
 * @Author Ralph Hauwert
 */
 
import flash.display.Graphics;

import org.papervision3d.core.render.data.RenderSessionData;

class AbstractRenderListItem implements IRenderListItem
{
	public var screenZ:Float;
	
	public function new()
	{
		
	}

	public function render(renderSessionData:RenderSessionData, graphics:Graphics):Void
	{
		
	}
	
}