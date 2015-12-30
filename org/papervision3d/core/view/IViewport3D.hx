package org.papervision3d.core.view;

import org.papervision3d.core.render.data.RenderSessionData;

/**
 * @Author Ralph Hauwert
 */
interface IViewport3D
{
	function updateBeforeRender(renderSessionData:RenderSessionData):Void;
	function updateAfterRender(renderSessionData:RenderSessionData):Void;
}