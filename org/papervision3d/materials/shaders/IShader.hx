package org.papervision3d.materials.shaders;

import flash.display.BitmapData;

import org.papervision3d.core.geom.renderables.Triangle3D;
import org.papervision3d.core.render.data.RenderSessionData;
import org.papervision3d.core.render.shader.ShaderObjectData;

/**
 * @Author Ralph Hauwert
 */
interface IShader
{
	function renderLayer(triangle:Triangle3D, renderSessionData:RenderSessionData,sod:ShaderObjectData):Void;
	function renderTri(triangle:Triangle3D, renderSessionData:RenderSessionData,sod:ShaderObjectData,bmp:BitmapData):Void;
	function updateAfterRender(renderSessionData:RenderSessionData, sod:ShaderObjectData):Void;
	function destroy():Void;
}