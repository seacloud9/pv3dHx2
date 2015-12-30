package org.papervision3d.core.log;


/**
 * @author Ralph Hauwert
 */

interface IPaperLogger
{
	function log(msg:String, object:Dynamic=null, arguments:Array<Dynamic>=null):Void;
	function info(msg:String, object:Dynamic=null, arguments:Array<Dynamic>=null):Void;
	function debug(msg:String, object:Dynamic=null, arguments:Array<Dynamic>=null):Void;
	function warning(msg:String, object:Dynamic=null, arguments:Array<Dynamic>=null):Void;
	function error(msg:String, object:Dynamic=null, arguments:Array<Dynamic>=null):Void;
	function fatal(msg:String, object:Dynamic=null, arguments:Array<Dynamic>=null):Void;
		
}