package org.papervision3d.core.render.shader;

import flash.display.Sprite;

import org.papervision3d.core.render.data.RenderSessionData;
import org.papervision3d.materials.shaders.Shader;

interface IShaderRenderer
{
	function render(renderSessionData:RenderSessionData):Void;
	function clear():Void;
	function getLayerForShader(shader:Shader):Sprite;
	function destroy():Void;
}