package org.papervision3d.core.render.command;


/**
 * @Author Ralph Hauwert
 */
 
import flash.display.Graphics;

import org.papervision3d.core.render.data.RenderSessionData;

interface IRenderListItem
{
	function render(renderSessionData:RenderSessionData, graphics:Graphics):Void;
}