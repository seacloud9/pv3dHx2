package org.papervision3d.core.data;


/**
 * @author Ralph Hauwert
 */

class UserData
{
	
	public var data:Dynamic;
	
	/**
	 * UserData();
	 * 
	 * The UserData class abstracts an end-user defined data object.
	 * 
	 * The UserData class itself can be extends for more typed setting of data.
	 */
	public function new(data:Dynamic=null)
	{
		this.data=data;
	}
	
}