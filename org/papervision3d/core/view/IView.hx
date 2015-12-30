package org.papervision3d.core.view;

/**
 * @Author Ralph Hauwert
 */
interface IView
{
	function singleRender():Void;
	function startRendering():Void;
	function stopRendering(reRender:Bool=false, cacheAsBitmap:Bool=false):Void;
}