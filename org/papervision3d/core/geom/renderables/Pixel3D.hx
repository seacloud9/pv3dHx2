package org.papervision3d.core.geom.renderables;


/**
 * @author Andy Zupko.
 */
 
import org.papervision3d.core.geom.Pixels;

class Pixel3D
{

	public var vertex3D:Vertex3D;
	public var color:Int;
	public var instance:Pixels;
	
	public function new(color:Int, x:Float=0, y:Float=0, z:Float=0)
	{
		this.color=color;
		vertex3D=new Vertex3D(x,y,z);
	}
	
	public var x(null, set_x):Float;
 	private function set_x(x:Float):Void
	{
		vertex3D.x=x;
	}
	
	public function get x():Float
	{
		return vertex3D.x;
	}
	
	public var y(null, set_y):Float;
 	private function set_y(y:Float):Void
	{
		vertex3D.y=y;
	}
	
	public function get y():Float
	{
		return vertex3D.y;
	}
	
	public var z(null, set_z):Float;
 	private function set_z(z:Float):Void
	{
		vertex3D.z=z;
	}
	
	public function get z():Float
	{
		return vertex3D.z;
	}
	
	
}