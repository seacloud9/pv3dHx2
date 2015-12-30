package org.papervision3d.core.log;

class PaperTraceLogger extends AbstractPaperLogger implements IPaperLogger
{
	public function new()
	{
		super();
	}
	
	override public function log(msg:String, object:Dynamic=null, arguments:Array<Dynamic>=null):Void
	{
		trace("LOG:",msg, arguments);
	}
	
	override public function info(msg:String, object:Dynamic=null, arguments:Array<Dynamic>=null):Void
	{
		trace("INFO:",msg, arguments);
	}
	
	override public function debug(msg:String, object:Dynamic=null, arguments:Array<Dynamic>=null):Void
	{
		trace("DEBUG:",msg, arguments);
	}
	
	override public function warning(msg:String, object:Dynamic=null, arguments:Array<Dynamic>=null):Void
	{
		trace("WARNING:",msg, arguments);
	}
	
	override public function error(msg:String, object:Dynamic=null, arguments:Array<Dynamic>=null):Void
	{
		trace("ERROR:",msg, arguments);
	}
	
	override public function fatal(msg:String, object:Dynamic=null, arguments:Array<Dynamic>=null):Void
	{
		trace("FATAL:",msg, arguments);
	}
	
}