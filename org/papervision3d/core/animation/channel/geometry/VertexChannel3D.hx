package org.papervision3d.core.animation.channel.geometry 
{
import org.papervision3d.core.animation.channel.Channel3D;	
import org.papervision3d.core.geom.renderables.Vertex3D;
import org.papervision3d.core.proto.GeometryObject3D;	

/**
 * The VertexChannel3D class animates a single vertex in a GeometryObject3D.
 * 
 *<p>You can animate a single property of the vertex("x", "y" or "z"), or alternatively
 * you can animate all 3 properties of the vertex.</p>
 * 
 * @see org.papervision3d.core.animation.channel.Channel3D
 * @see org.papervision3d.core.proto.GeometryObject3D
 * @see org.papervision3d.core.geom.renderables.Vertex3D
 * 
 * @author Tim Knip / floorplanner.com
 */
class VertexChannel3D extends GeometryChannel3D 
{
	public static var TARGET_X 	:Int=0;
	public static var TARGET_Y 	:Int=1;
	public static var TARGET_Z 	:Int=2;
	public static var TARGET_XYZ 	:Int=-1;
	
	/**
	 * The index of the targeted vertex.
	 */
	public var vertexIndex:Int;
	
	/**
	 * The targeted property of the targeted vertex.
	 * Possible values are #TARGET_X, #TARGET_Y, #TARGET_Z or #TARGET_XYZ
	 */
	public var vertexProperty:Int;
	
	/**
	 * 
	 */
	private var _clone:GeometryObject3D;

	/**
	 * Constructor
	 */
	public function new(geometry:GeometryObject3D, vertexIndex:Int, vertexProperty:Int=-1)
	{
		super(geometry);
		
		this.vertexIndex=vertexIndex;
		this.vertexProperty=vertexProperty;
	}

	/**
	 * 
	 */
	override public function update(time:Float):Void 
	{
		if(!_curves || !_geometry || !_clone)
		{
			return;
		}
		
		super.update(time);
		
		var o:Vertex3D=_clone.vertices[vertexIndex];
		var t:Vertex3D=_geometry.vertices[vertexIndex];
		var numCurves:Int=_curves.length;
		
		if(vertexProperty==TARGET_XYZ && numCurves==3)
		{
			t.x=o.x + output[0];
			t.y=o.y + output[1];
			t.z=o.z + output[2];
		}
		else if(numCurves==1)
		{
			var prop:String=vertexProperty==0 ? "x":(vertexProperty==1 ? "y":"z");
			
			t[prop]=o[prop] + output[0];
		}
	}

	/**
	 * 
	 */
	override public var geometry(null, set_geometry):GeometryObject3D;
 	private function set_geometry(value:GeometryObject3D):Void 
	{
		super.geometry=value;
		if(_geometry && _geometry.vertices && _geometry.vertices.length)
		{
			_clone=_geometry.clone();
		}
	}
}