package org.papervision3d.core.log;

import org.papervision3d.core.log.event.PaperLoggerEvent;

/**
 * @author Ralph Hauwert
 */

class AbstractPaperLogger implements IPaperLogger
{
	public function new()
	{
		
	}
	
	private function onLogEvent(event:PaperLoggerEvent):Void
	{
		var logVO:PaperLogVO=event.paperLogVO;
		switch(logVO.level){
			case LogLevel.LOG:
				log(logVO.msg, logVO.object, logVO.arg);
			break;
			case LogLevel.INFO:
				info(logVO.msg, logVO.object, logVO.arg);
			break;
			case LogLevel.ERROR:
				error(logVO.msg, logVO.object, logVO.arg);
			break;
			case LogLevel.DEBUG:
				debug(logVO.msg, logVO.object, logVO.arg);
			break;
			case LogLevel.WARNING:
				warning(logVO.msg, logVO.object, logVO.arg);
			break;
			case LogLevel.FATAL:
				fatal(logVO.msg, logVO.object, logVO.arg);
			break;
			default:
				log(logVO.msg, logVO.object, logVO.arg);
			break;
		}	
	}
	
	public function log(msg:String, object:Dynamic=null, arg:Array<Dynamic>=null):Void
	{
		
	}
	
	public function info(msg:String, object:Dynamic=null, arg:Array<Dynamic>=null):Void
	{
		
	}
	
	public function debug(msg:String, object:Dynamic=null, arg:Array<Dynamic>=null):Void
	{
		
	}
	
	public function warning(msg:String, object:Dynamic=null, arg:Array<Dynamic>=null):Void
	{
		
	}
	
	public function error(msg:String, object:Dynamic=null, arg:Array<Dynamic>=null):Void
	{
		
	}
	
	public function fatal(msg:String, object:Dynamic=null, arg:Array<Dynamic>=null):Void
	{
		
	}
	
	public function registerWithPaperLogger(paperLogger:PaperLogger):Void
	{
		paperLogger.addEventListener(PaperLoggerEvent.TYPE_LOGEVENT, onLogEvent);
	}
	
	public function unregisterFromPaperLogger(paperLogger:PaperLogger):Void
	{
		paperLogger.removeEventListener(PaperLoggerEvent.TYPE_LOGEVENT, onLogEvent);
	}
	
}