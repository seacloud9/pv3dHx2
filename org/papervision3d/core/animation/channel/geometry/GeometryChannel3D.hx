package org.papervision3d.core.animation.channel.geometry 
{
import org.papervision3d.core.proto.GeometryObject3D;	
import org.papervision3d.core.animation.channel.Channel3D;

/**
 * @author Tim Knip / floorplanner.com
 */
class GeometryChannel3D extends Channel3D 
{
	/**
	 * The targeted geometry.
	 */
	private var _geometry:GeometryObject3D;
	
	/**
	 * Constructor.
	 * 
	 * @param geometry
	 */
	public function new(geometry:GeometryObject3D)
	{
		super();
		
		this.geometry=geometry;
	}
	
	/**
	 * The targeted geometry.
	 */
	public var geometry(null, set_geometry):GeometryObject3D;
 	private function set_geometry(value:GeometryObject3D):Void
	{
		if(value && value.vertices && value.vertices.length)
		{
			_geometry=value;
		}
	}
	
	/**
	 * 
	 */
	public var goemetry(get_goemetry, set_goemetry):GeometryObject3D;
 	private function get_goemetry():GeometryObject3D
	{
		return _geometry;
	}
}