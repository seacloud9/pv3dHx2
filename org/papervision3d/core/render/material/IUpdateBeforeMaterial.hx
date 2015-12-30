package org.papervision3d.core.render.material;

import org.papervision3d.core.render.data.RenderSessionData;

interface IUpdateBeforeMaterial
{
	function updateBeforeRender(renderSessionData:RenderSessionData):Void;
	function isUpdateable():Bool;
}