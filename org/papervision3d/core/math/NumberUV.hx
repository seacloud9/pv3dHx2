package org.papervision3d.core.math;

/**
* The FloatUV class represents a value in a texture UV coordinate system.
*
* Properties u and v represent the horizontal and vertical texture axes respectively.
*
*/
class FloatUV
{
/**
* The horizontal coordinate value.
*/
public var u:Float;

/**
* The vertical coordinate value.
*/
public var v:Float;

/**
* Creates a new FloatUV object whose coordinate values are specified by the u and v parameters. If you call this constructor function without parameters, a FloatUV with u and v properties set to zero is created.
*
* @param	u	The horizontal coordinate value. The default value is zero.
* @param	v	The vertical coordinate value. The default value is zero.
*/
public function new(u:Float=0, v:Float=0)
{
	this.u=u;
	this.v=v;
}


/**
* Returns a new FloatUV object that is a clone of the original instance with the same UV values.
*
* @return	A new FloatUV instance with the same UV values as the original FloatUV instance.
*/
public function clone():FloatUV
{
	return new FloatUV(this.u, this.v);
}


/**
* Returns a FloatUV object with u and v properties set to zero.
*
* @return A FloatUV object.
*/
static public var ZERO(get_ZERO, null):FloatUV;
 	private function get_ZERO():FloatUV
{
	return new FloatUV(0, 0);
}


/**
* Returns a string value representing the UV values in the specified FloatUV object.
*
* @return	A string.
*/
public function toString():String
{
	return 'u:' + u + ' v:' + v;
}

public static function weighted(a:FloatUV, b:FloatUV, aw:Float, bw:Float):FloatUV
	{				
		if(a==null)
			return null;
		if(b==null)
			return null;
		var d:Float=aw + bw;
		var ak:Float=aw / d;
		var bk:Float=bw / d;
		return new FloatUV(a.u*ak+b.u*bk, a.v*ak + b.v*bk);
	}

public static function median(a:FloatUV, b:FloatUV):FloatUV
	{
		if(a==null)
			return null;
		if(b==null)
			return null;
		return new FloatUV((a.u + b.u)/2,(a.v + b.v)/2);
	}
}