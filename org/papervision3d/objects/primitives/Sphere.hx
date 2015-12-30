package org.papervision3d.objects.primitives {
import org.papervision3d.Papervision3D;
import org.papervision3d.core.geom.*;
import org.papervision3d.core.geom.renderables.Triangle3D;
import org.papervision3d.core.geom.renderables.Vertex3D;
import org.papervision3d.core.math.NumberUV;
import org.papervision3d.core.proto.*;	

/**
* The Sphere class lets you create and display spheres.
*<p/>
* The sphere is divided in vertical and horizontal segment, the smallest combination is two vertical and three horizontal segments.
*/
class Sphere extends TriangleMesh3D
{
	/**
	* Float of segments horizontally. Defaults to 8.
	*/
	private var segmentsW:Float;

	/**
	* Float of segments vertically. Defaults to 6.
	*/
	private var segmentsH:Float;

	/**
	* Default radius of Sphere if not defined.
	*/
	static public var DEFAULT_RADIUS:Float=100;

	/**
	* Default scale of Sphere texture if not defined.
	*/
	static public var DEFAULT_SCALE:Float=1;

	/**
	* Default value of gridX if not defined.
	*/
	static public var DEFAULT_SEGMENTSW:Float=8;

	/**
	* Default value of gridY if not defined.
	*/
	static public var DEFAULT_SEGMENTSH:Float=6;

	/**
	* Minimum value of gridX.
	*/
	static public var MIN_SEGMENTSW:Float=3;

	/**
	* Minimum value of gridY.
	*/
	static public var MIN_SEGMENTSH:Float=2;


	// ___________________________________________________________________________________________________
	//																							   N E W
	// NN  NN EEEEEE WW	WW
	// NNN NN EE	 WW WW WW
	// NNNNNN EEEE   WWWWWWWW
	// NN NNN EE	 WWW  WWW
	// NN  NN EEEEEE WW	WW

	/**
	* Create a new Sphere object.
	*<p/>
	* @param	material	A MaterialObject3D object that contains the material properties of the object.
	*<p/>
	* @param	radius		[optional] - Desired radius.
	*<p/>
	* @param	segmentsW	[optional] - Float of segments horizontally. Defaults to 8.
	*<p/>
	* @param	segmentsH	[optional] - Float of segments vertically. Defaults to 6.
	*<p/>
	*/
	public function new(material:MaterialObject3D=null, radius:Float=100, segmentsW:Int=8, segmentsH:Int=6)
	{
		super(material, new Array(), new Array(), null);

		this.segmentsW=Math.max(MIN_SEGMENTSW, segmentsW || DEFAULT_SEGMENTSW);// Defaults to 8
		this.segmentsH=Math.max(MIN_SEGMENTSH, segmentsH || DEFAULT_SEGMENTSH);// Defaults to 6
		if(radius==0)radius=DEFAULT_RADIUS;// Defaults to 100

		var scale:Float=DEFAULT_SCALE;

		buildSphere(radius);
	}

	private function buildSphere(fRadius:Float):Void
	{
		var i:Float, j:Float, k:Float;
		var iHor:Float=Math.max(3,this.segmentsW);
		var iVer:Float=Math.max(2,this.segmentsH);
		var aVertice:Array<Dynamic>=this.geometry.vertices;
		var aFace:Array<Dynamic>=this.geometry.faces;
		var aVtc:Array<Dynamic>=new Array();
		for(j=0;j<(iVer+1);j++){ // vertical
			var fRad1:Float=Std.parseFloat(j/iVer);
			var fZ:Float=-fRadius*Math.cos(fRad1*Math.PI);
			var fRds:Float=fRadius*Math.sin(fRad1*Math.PI);
			var aRow:Array<Dynamic>=new Array();
			var oVtx:Vertex3D;
			for(i=0;i<iHor;i++){ // horizontal
				var fRad2:Float=Std.parseFloat(2*i/iHor);
				var fX:Float=fRds*Math.sin(fRad2*Math.PI);
				var fY:Float=fRds*Math.cos(fRad2*Math.PI);
				if(!((j==0||j==iVer)&&i>0)){ // top||bottom=1 vertex
					oVtx=new Vertex3D(fY,fZ,fX);
					aVertice.push(oVtx);
				}
				aRow.push(oVtx);
			}
			aVtc.push(aRow);
		}
		var iVerNum:Int=aVtc.length;
		for(j=0;j<iVerNum;j++){
			var iHorNum:Int=aVtc[j].length;
			if(j>0){ // &&i>=0
				for(i=0;i<iHorNum;i++){
					// select vertices
					var bEnd:Bool=i==(iHorNum-1);
					var aP1:Vertex3D=aVtc[j][bEnd?0:i+1];
					var aP2:Vertex3D=aVtc[j][(bEnd?iHorNum-1:i)];
					var aP3:Vertex3D=aVtc[j-1][(bEnd?iHorNum-1:i)];
					var aP4:Vertex3D=aVtc[j-1][bEnd?0:i+1];
					// uv
					/*
					 * fix applied as suggested by Philippe to correct the uv mapping on a sphere
					 * */
					var fJ0:Float=j		/(iVerNum-1);
					var fJ1:Float=(j-1)	/(iVerNum-1);
					var fI0:Float=(i+1)	/ iHorNum;
					var fI1:Float=i		/ iHorNum;
					var aP4uv:FloatUV=new FloatUV(fI0,fJ1);
					var aP1uv:FloatUV=new FloatUV(fI0,fJ0);
					var aP2uv:FloatUV=new FloatUV(fI1,fJ0);
					var aP3uv:FloatUV=new FloatUV(fI1,fJ1);
					// 2 faces
					if(j<(aVtc.length-1))	aFace.push(new Triangle3D(this, new Array(aP1,aP2,aP3), material, new Array(aP1uv,aP2uv,aP3uv)));
					if(j>1)				aFace.push(new Triangle3D(this, new Array(aP1,aP3,aP4), material, new Array(aP1uv,aP3uv,aP4uv)));

				}
			}
		}
		for(var t:Triangle3D in aFace){
			t.renderCommand.create=createRenderTriangle;
		}
		
		this.geometry.ready=true;
		
		if(Papervision3D.useRIGHTHANDED)
			this.geometry.flipFaces();
	}
}