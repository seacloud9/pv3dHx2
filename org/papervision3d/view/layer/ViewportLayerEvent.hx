package org.papervision3d.view.layer;

import flash.events.Event;

import org.papervision3d.objects.DisplayObject3D;

class ViewportLayerEvent extends Event
{
	public var do3d:DisplayObject3D;
	public var layer:ViewportLayer;
	
	public function new(type:String, do3d:DisplayObject3D=null, layer:ViewportLayer=null)
	{
		super(type, false, false);
		this.do3d=do3d;
		this.layer=layer;
	}
	
	public static inline var CHILD_ADDED:String="childAdded";
	public static inline var CHILD_REMOVED:String="childRemoved";
	
}