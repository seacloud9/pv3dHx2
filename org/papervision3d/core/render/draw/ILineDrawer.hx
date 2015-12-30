package org.papervision3d.core.render.draw;


/**
 * @Author Ralph Hauwert
 */
 
import flash.display.Graphics;

import org.papervision3d.core.render.command.RenderLine;
import org.papervision3d.core.render.data.RenderSessionData;

interface ILineDrawer
{
	function drawLine(line:RenderLine, graphics:Graphics, renderSessionData:RenderSessionData):Void;
}