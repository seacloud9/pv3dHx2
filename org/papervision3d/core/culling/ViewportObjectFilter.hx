package org.papervision3d.core.culling;

import flash.utils.Dictionary;

import org.papervision3d.objects.DisplayObject3D;


/**
 * @Author Ralph Hauwert
 */
class ViewportObjectFilter implements IObjectCuller
{
	
	private var _mode:Int;
	private var objects:Dictionary;
	
	public function new(mode:Int):Void
	{
		this.mode=mode;
		init();
	}
	
	private function init():Void
	{
		objects=new Dictionary(true);
	}
	
	public function testObject(object:DisplayObject3D):Int
	{
		if(objects[object]){
			return 1-_mode;
		}else{
			return mode;
		}
		return 0;
	}
	
	public function addObject(do3d:DisplayObject3D):Void
	{
		objects[do3d]=do3d;
	}
	
	public function removeObject(do3d:DisplayObject3D):Void
	{
		delete objects[do3d];
	}
	
	private function set_mode(mode:Int):Void
	{
		_mode=mode;	
	}
	
	public var mode(get_mode, set_mode):Int;
 	private function get_mode():Int
	{
		return _mode;
	}
	
	public function destroy():Void
	{
		objects=null;
	}
	
}