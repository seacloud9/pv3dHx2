package org.papervision3d.core.culling 
{
import org.papervision3d.objects.DisplayObject3D;

/**
 * @author Tim Knip 
 */
interface IObjectCuller 
{
	function testObject(object:DisplayObject3D):Int;
}