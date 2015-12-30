package org.papervision3d.core.log;


/**
 * @author Ralph Hauwert
 */
class PaperLogVO
{
	
	public var level:Int;
	public var msg:String;
	public var object:Dynamic;
	public var arg:Array<Dynamic>;
	
	public function new(level:Int, msg:String, object:Dynamic, arg:Array)
	{
		this.level=level;
		this.msg=msg;
		this.object=object;
		this.arg=arg;	
	}

}