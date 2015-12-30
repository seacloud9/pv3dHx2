package org.papervision3d.objects.primitives {
import org.papervision3d.Papervision3D;
import org.papervision3d.core.geom.*;
import org.papervision3d.core.geom.renderables.Triangle3D;
import org.papervision3d.core.geom.renderables.Vertex3D;
import org.papervision3d.core.log.PaperLogger;
import org.papervision3d.core.math.Number3D;
import org.papervision3d.core.math.NumberUV;
import org.papervision3d.core.proto.*;
import org.papervision3d.materials.utils.MaterialsList;	

/**
* The Cube class lets you create and display flat rectangle objects.
*<p/>
* The rectangle can be divided in smaller segments. This is usually done to reduce linear mapping artifacts.
*<p/>
* Dividing the Cube in the direction of the perspective or vanishing point, helps to reduce this problem. Perspective distortion dissapears when the Cube is facing straignt to the camera, i.e. it is perpendicular with the vanishing point of the scene.
*/
class Cube extends TriangleMesh3D
{
	/**
	* Float of segments per axis. Defaults to 1.
	*/
	public var segments:Float3D;

	/**
	* No faces selected.
	*/
	static public var NONE:Int=0x00;

	/**
	* Front face selection
	*/
	static public var FRONT:Int=0x01;

	/**
	* Back face selection
	*/
	static public var BACK:Int=0x02;

	/**
	* Right face selection
	*/
	static public var RIGHT:Int=0x04;

	/**
	* Left face selection
	*/
	static public var LEFT:Int=0x08;

	/**
	* Top face selection
	*/
	static public var TOP	:Int=0x10;

	/**
	* Bottom face selection
	*/
	static public var BOTTOM:Int=0x20;

	/**
	* All faces selected.
	*/
	static public var ALL	:Int=FRONT + BACK + RIGHT + LEFT + TOP + BOTTOM;
	
	private var insideFaces:Int;
	private var excludeFaces:Int;

	// ___________________________________________________________________________________________________
	//																							   N E W
	// NN  NN EEEEEE WW	WW
	// NNN NN EE	 WW WW WW
	// NNNNNN EEEE   WWWWWWWW
	// NN NNN EE	 WWW  WWW
	// NN  NN EEEEEE WW	WW

	/**
	* Create a new Cube object.
	*<p/>
	* @param	materials	A MaterialObject3D object that contains the material properties of the object.
	* 
	* Supported materials are:front, back, right, left, top, bottom & all, for example:
	* 
	*	var materials:MaterialsList=new MaterialsList(
	*	{
	*		all:	new MovieAssetMaterial("Front", true), // This is the default material
	*		front:new MovieAssetMaterial("Front", true),
	*		back:new MovieAssetMaterial("Back", true),
	*		right:new MovieAssetMaterial("Right", true),
	*		left:new MovieAssetMaterial("Left", true),
	*		top:	new MovieAssetMaterial("Top", true),
	*		bottom:new MovieAssetMaterial("Bottom", true)
	*	});
	* 
	*<p/>
	* @param	width			[optional] - Desired width.
	*<p/>
	* @param	depth			[optional] - Desired depth.
	*<p/>
	* @param	height			[optional] - Desired height.
	*<p/>
	* @param	segmentsS		[optional] - Float of segments sagitally(plane perpendicular to width). Defaults to 1.
	*<p/>
	* @param	segmentsT		[optional] - Float of segments transversally(plane perpendicular to depth). Defaults to segmentsS.
	*<p/>
	* @param	segmentsH		[optional] - Float of segments horizontally(plane perpendicular to height). Defaults to segmentsS.
	*<p/>
	* @param	insideFaces		[optional] - Faces that are visible from the inside. Defaults to Cube.NONE.
	*
	* You can add or sustract faces to your selection. For examples:Cube.FRONT+Cube.BACK or Cube.ALL-Cube.Top.
	* 
	*<p/>
	* @param	excludeFaces	[optional] - Faces that will not be created. Defaults to Cube.NONE.
	* 
	* You can add or sustract faces to your selection. For examples:Cube.FRONT+Cube.BACK or Cube.ALL-Cube.Top.
	* 
	*<p/>
	*/
	public function new(materials:MaterialsList, width:Float=500, depth:Float=500, height:Float=500, segmentsS:Int=1, segmentsT:Int=1, segmentsH:Int=1, insideFaces:Int=0, excludeFaces:Int=0)
	{
		super(materials.getMaterialByName("all"), new Array(), new Array(), null);
		
		this.materials=materials;
		
		this.insideFaces=insideFaces;
		this.excludeFaces=excludeFaces;

		segments=new Float3D(segmentsS, segmentsT, segmentsH);

		buildCube(width, height, depth);
	}

	private function buildCube(width:Float, height:Float, depth:Float):Void
	{
		var width2:Float=width  /2;
		var height2:Float=height /2;
		var depth2:Float=depth  /2;
		
		if(!(excludeFaces & FRONT))
			buildPlane("front", "x", "y", width, height, depth2, ! Bool(insideFaces & FRONT));

		if(!(excludeFaces & BACK))
			buildPlane("back", "x", "y", width, height, -depth2, Bool(insideFaces & BACK));

		if(!(excludeFaces & RIGHT))
			buildPlane("right", "z", "y", depth, height, width2, Bool(insideFaces & RIGHT));

		if(!(excludeFaces & LEFT))
			buildPlane("left", "z", "y", depth, height, -width2, ! Bool(insideFaces & LEFT));

		if(!(excludeFaces & TOP))
			buildPlane("top", "x", "z", width, depth, height2, Bool(insideFaces & TOP));

		if(!(excludeFaces & BOTTOM))
			buildPlane("bottom", "x", "z", width, depth, -height2, ! Bool(insideFaces & BOTTOM));

		mergeVertices();
		
		for(var t:Triangle3D in this.geometry.faces){
			t.renderCommand.create=createRenderTriangle;
		}
		
		this.geometry.ready=true;
		
		if(Papervision3D.useRIGHTHANDED)
			this.geometry.flipFaces();
	}

	private function buildPlane(mat:String, u:String, v:String, width:Float, height:Float, depth:Float, reverse:Bool=false):Void
	{
		var matInstance:MaterialObject3D;
		if(!(matInstance=materials.getMaterialByName(mat)))
		{
			if(!(matInstance=materials.getMaterialByName("all"))){
				PaperLogger.warning("Required material not found in given materials list. Supported materials are:front, back, right, left, top, bottom & all.");
				return;
			}
			
		}
		
		matInstance.registerObject(this);// needed for the shaders.
		// Find w depth axis
		var w:String;
		if((u=="x" && v=="y")||(u=="y" && v=="x"))w="z";
		else if((u=="x" && v=="z")||(u=="z" && v=="x"))w="y";
		else if((u=="z" && v=="y")||(u=="y" && v=="z"))w="x";

		// Mirror
		var rev:Float=reverse? -1:1;

		// Build plane
		var gridU	:Float=this.segments[ u ];
		var gridV	:Float=this.segments[ v ];
		var gridU1:Float=gridU + 1;
		var gridV1:Float=gridV + 1;

		var vertices:Array<Dynamic>=this.geometry.vertices;
		var faces	:Array<Dynamic>=this.geometry.faces;
		var planeVerts:Array<Dynamic>=new Array();

		var textureU:Float=width /2;
		var textureV:Float=height /2;

		var incU	:Float=width / gridU;
		var incV	:Float=height / gridV;

		// Vertices
		for(iu in 0...gridU1)
		{
			for(iv in 0...gridV1)
			{
				var vertex:Vertex3D=new Vertex3D();
				
				vertex[ u ]=(iu * incU - textureU)* rev;
				vertex[ v ]=iv * incV - textureV;
				vertex[ w ]=depth;
				
				vertices.push(vertex);
				planeVerts.push(vertex);
			}
		}

		// Faces
		var uvA:FloatUV;
		var uvC:FloatUV;
		var uvB:FloatUV;

		for(iu=0;iu<gridU;iu++)
		{
			for(iv=0;iv<gridV;iv++)
			{
				// Triangle A
				var a:Vertex3D=planeVerts[ iu	 * gridV1 + iv	 ];
				var c:Vertex3D=planeVerts[ iu	 * gridV1 +(iv+1)];
				var b:Vertex3D=planeVerts[(iu+1)* gridV1 + iv	 ];

				uvA=new FloatUV(iu	 / gridU, iv	 / gridV);
				uvC=new FloatUV(iu	 / gridU,(iv+1)/ gridV);
				uvB=new FloatUV((iu+1)/ gridU, iv	 / gridV);

				faces.push(new Triangle3D(this, [ a, b, c ], matInstance, [ uvA, uvB, uvC ]));

				// Triangle B
				a=planeVerts[(iu+1)* gridV1 +(iv+1)];
				c=planeVerts[(iu+1)* gridV1 + iv	 ];
				b=planeVerts[ iu	 * gridV1 +(iv+1)];

				uvA=new FloatUV((iu+1)/ gridU,(iv+1)/ gridV);
				uvC=new FloatUV((iu+1)/ gridU, iv	 / gridV);
				uvB=new FloatUV(iu	 / gridU,(iv+1)/ gridV);

				faces.push(new Triangle3D(this, [ c, a, b ], matInstance, [ uvC, uvA, uvB ]));
			}
		}
	}
	
	public function destroy():Void
	{
		var mat:MaterialObject3D;
		for(mat in materials){
			mat.unregisterObject(this);
		}
	}
	
	
}