package org.papervision3d.objects.primitives {
import org.papervision3d.Papervision3D;
import org.papervision3d.core.geom.*;
import org.papervision3d.core.geom.renderables.Triangle3D;
import org.papervision3d.core.geom.renderables.Vertex3D;
import org.papervision3d.core.math.NumberUV;
import org.papervision3d.core.proto.*;	

/**
* The Plane class lets you create and display flat rectangle objects.
*<p/>
* The rectangle can be divided in smaller segments. This is usually done to reduce linear mapping artifacts.
*<p/>
* Dividing the plane in the direction of the perspective or vanishing point, helps to reduce this problem. Perspective distortion dissapears when the plane is facing straignt to the camera, i.e. it is perpendicular with the vanishing point of the scene.
*/
class Plane extends TriangleMesh3D
{
	/**
	* Float of segments horizontally. Defaults to 1.
	*/
	public var segmentsW:Float;

	/**
	* Float of segments vertically. Defaults to 1.
	*/
	public var segmentsH:Float;

	/**
	* Default size of Plane if not texture is defined.
	*/
	static public var DEFAULT_SIZE:Float=500;

	/**
	* Default size of Plane if not texture is defined.
	*/
	static public var DEFAULT_SCALE:Float=1;

	/**
	* Default value of gridX if not defined. The default value of gridY is gridX.
	*/
	static public var DEFAULT_SEGMENTS:Float=1;


	// ___________________________________________________________________________________________________
	//																							   N E W
	// NN  NN EEEEEE WW	WW
	// NNN NN EE	 WW WW WW
	// NNNNNN EEEE   WWWWWWWW
	// NN NNN EE	 WWW  WWW
	// NN  NN EEEEEE WW	WW

	/**
	* Create a new Plane object.
	*<p/>
	* @param	material	A MaterialObject3D object that contains the material properties of the object.
	*<p/>
	* @param	width		[optional] - Desired width or scaling factor if there's bitmap texture in material and no height is supplied.
	*<p/>
	* @param	height		[optional] - Desired height.
	*<p/>
	* @param	segmentsW	[optional] - Float of segments horizontally. Defaults to 1.
	*<p/>
	* @param	segmentsH	[optional] - Float of segments vertically. Defaults to segmentsW.
	*<p/>
	*/
	public function new(material:MaterialObject3D=null, width:Float=0, height:Float=0, segmentsW:Float=0, segmentsH:Float=0)
	{
		super(material, new Array(), new Array(), null);

		this.segmentsW=segmentsW || DEFAULT_SEGMENTS;// Defaults to 1
		this.segmentsH=segmentsH || this.segmentsW;// Defaults to segmentsW

		var scale:Float=DEFAULT_SCALE;

		if(! height)
		{
			if(width)
				scale=width;

			if(material && material.bitmap)
			{
				width=material.bitmap.width  * scale;
				height=material.bitmap.height * scale;
			}
			else
			{
				width=DEFAULT_SIZE * scale;
				height=DEFAULT_SIZE * scale;
			}
		}

		buildPlane(width, height);
	}

	private function buildPlane(width:Float, height:Float):Void
	{
		var gridX	:Float=this.segmentsW;
		var gridY	:Float=this.segmentsH;
		var gridX1:Float=gridX + 1;
		var gridY1:Float=gridY + 1;

		var vertices:Array<Dynamic>=this.geometry.vertices;
		var faces	:Array<Dynamic>=this.geometry.faces;

		var textureX:Float=width /2;
		var textureY:Float=height /2;

		var iW	:Float=width / gridX;
		var iH	:Float=height / gridY;

		// Vertices
		for(var ix:Int=0;ix<gridX + 1;ix++)
		{
			for(iy in 0...gridY1)
			{
				var x:Float=ix * iW - textureX;
				var y:Float=iy * iH - textureY;

				vertices.push(new Vertex3D(x, y, 0));
			}
		}

		// Faces
		var uvA:FloatUV;
		var uvC:FloatUV;
		var uvB:FloatUV;

		for(ix=0;ix<gridX;ix++)
		{
			for(iy=0;iy<gridY;iy++)
			{
				// Triangle A
				var a:Vertex3D=vertices[ ix	 * gridY1 + iy	 ];
				var c:Vertex3D=vertices[ ix	 * gridY1 +(iy+1)];
				var b:Vertex3D=vertices[(ix+1)* gridY1 + iy	 ];

				uvA=new FloatUV(ix	 / gridX, iy	 / gridY);
				uvC=new FloatUV(ix	 / gridX,(iy+1)/ gridY);
				uvB=new FloatUV((ix+1)/ gridX, iy	 / gridY);

				faces.push(new Triangle3D(this, [ a, b, c ], material, [ uvA, uvB, uvC ]));

				// Triangle B
				a=vertices[(ix+1)* gridY1 +(iy+1)];
				c=vertices[(ix+1)* gridY1 + iy	 ];
				b=vertices[ ix	 * gridY1 +(iy+1)];

				uvA=new FloatUV((ix+1)/ gridX,(iy+1)/ gridY);
				uvC=new FloatUV((ix+1)/ gridX, iy	  / gridY);
				uvB=new FloatUV(ix	  / gridX,(iy+1)/ gridY);
				
				faces.push(new Triangle3D(this, [ a, b, c ], material, [ uvA, uvB, uvC ]));
			}
		}

		this.geometry.ready=true;
		
		if(Papervision3D.useRIGHTHANDED)
			this.geometry.flipFaces();
	}
}