package org.papervision3d.core.geom.renderables;

import org.papervision3d.core.data.UserData;
import org.papervision3d.core.render.command.IRenderListItem;
import org.papervision3d.objects.DisplayObject3D;

class AbstractRenderable implements IRenderable
{
	
	public var _userData:UserData;
	public var instance:DisplayObject3D;
	
	
	public function new()
	{
		super();
	}

	public function getRenderListItem():IRenderListItem
	{
		return null;
	}
	
	/**
	 * userData UserData
	 * 
	 * Optional extra data to be added to this object.
	 */
	private function set_userData(userData:UserData):Void
	{
		_userData=userData;
	}
	
	public var userData(get_userData, set_userData):UserData;
 	private function get_userData():UserData
	{
		return _userData;	
	}
	
}