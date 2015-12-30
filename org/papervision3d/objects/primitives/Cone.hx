package org.papervision3d.objects.primitives {
import org.papervision3d.core.proto.*;	

/**
* The Cone class lets you create and display Cones.
*<p/>
* The Cone is divided in vertical and horizontal segment, the smallest combination is two vertical and three horizontal segments.
*/
class Cone extends Cylinder
{
	// ___________________________________________________________________________________________________
	//																							   N E W
	// NN  NN EEEEEE WW	WW
	// NNN NN EE	 WW WW WW
	// NNNNNN EEEE   WWWWWWWW
	// NN NNN EE	 WWW  WWW
	// NN  NN EEEEEE WW	WW

	/**
	* Create a new Cone object.
	*<p/>
	* @param	material	A MaterialObject3D object that contains the material properties of the object.
	*<p/>
	* @param	radius		[optional] - Desired radius.
	*<p/>
	* @param	height		[optional] - Desired height.
	*<p/>
	* @param	segmentsW	[optional] - Float of segments horizontally. Defaults to 8.
	*<p/>
	* @param	segmentsH	[optional] - Float of segments vertically. Defaults to 6.
	*<p/>
	*/
	public function new(material:MaterialObject3D=null, radius:Float=100, height:Float=100, segmentsW:Int=8, segmentsH:Int=6)
	{
		super(material, radius, height, segmentsW, segmentsH, 0.0001);
	}
}