package org.papervision3d.events;

import flash.events.Event;

/**
* The FileLoadEvent class represents events that are dispatched when files are loaded.
*/
class FileLoadEvent extends Event
{
	public static var LOAD_COMPLETE 				:String="loadComplete";
	public static var LOAD_ERROR					:String="loadError";
	public static var SECURITY_LOAD_ERROR			:String="securityLoadError";
	public static var COLLADA_MATERIALS_DONE		:String="colladaMaterialsDone";
	public static var LOAD_PROGRESS 				:String="loadProgress";
	public static var ANIMATIONS_COMPLETE			:String="animationsComplete";
	public static var ANIMATIONS_PROGRESS			:String="animationsProgress";
		
	public var file:String="";
	public var bytesLoaded:Float=-1;
	public var bytesTotal:Float=-1;	
	public var message:String="";	
	public var dataObj:Dynamic=null;

	public function new(type:String, file:String="", bytesLoaded:Float=-1, bytesTotal:Float=-1, message:String="", dataObj:Dynamic=null, bubbles:Bool=false, cancelable:Bool=false)
	{
		super(type, bubbles, cancelable);
		this.file=file;
		this.bytesLoaded=bytesLoaded;
		this.bytesTotal=bytesTotal;
		this.message=message;
		this.dataObj=dataObj;
	} 
	
	public override function clone():Event
	{
		return new FileLoadEvent(type, file, bytesLoaded, bytesTotal, message, dataObj, bubbles, cancelable);
	}
}