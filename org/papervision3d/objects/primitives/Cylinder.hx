package org.papervision3d.objects.primitives {
import org.papervision3d.Papervision3D;
import org.papervision3d.core.geom.*;
import org.papervision3d.core.geom.renderables.Triangle3D;
import org.papervision3d.core.geom.renderables.Vertex3D;
import org.papervision3d.core.math.NumberUV;
import org.papervision3d.core.proto.*;	

/**
* The Cylinder class lets you create and display Cylinders.
*<p/>
* The Cylinder is divided in vertical and horizontal segment, the smallest combination is two vertical and three horizontal segments.
*/
class Cylinder extends TriangleMesh3D
{
	/**
	* Float of segments horizontally. Defaults to 8.
	*/
	public var segmentsW:Float;

	/**
	* Float of segments vertically. Defaults to 6.
	*/
	public var segmentsH:Float;

	/**
	* Default radius of Cylinder if not defined.
	*/
	static public static inline var DEFAULT_RADIUS:Float=100;

	/**
	* Default height if not defined.
	*/
	static public static inline var DEFAULT_HEIGHT:Float=100;

	/**
	* Default scale of Cylinder texture if not defined.
	*/
	static public static inline var DEFAULT_SCALE:Float=1;

	/**
	* Default value of gridX if not defined.
	*/
	static public static inline var DEFAULT_SEGMENTSW:Float=8;

	/**
	* Default value of gridY if not defined.
	*/
	static public static inline var DEFAULT_SEGMENTSH:Float=6;

	/**
	* Minimum value of gridX.
	*/
	static public static inline var MIN_SEGMENTSW:Float=3;

	/**
	* Minimum value of gridY.
	*/
	static public static inline var MIN_SEGMENTSH:Float=1;


	// ___________________________________________________________________________________________________
	//																							   N E W
	// NN  NN EEEEEE WW	WW
	// NNN NN EE	 WW WW WW
	// NNNNNN EEEE   WWWWWWWW
	// NN NNN EE	 WWW  WWW
	// NN  NN EEEEEE WW	WW

	/**
	* Create a new Cylinder object.
	*<p/>
	* @param	material	A MaterialObject3D object that contains the material properties of the object.
	*<p/>
	* @param	radius		[optional] - Desired radius.
	*<p/>
	* @param	segmentsW	[optional] - Float of segments horizontally. Defaults to 8.
	*<p/>
	* @param	segmentsH	[optional] - Float of segments vertically. Defaults to 6.
	*<p/>
	* @param	topRadius	[optional] - An optional parameter for con- or diverging cylinders.
	*<p/>
	* @param	topFace		[optional] - An optional parameter specifying if the top face of the cylinder should be drawn.
	*<p/>
	* @param	bottomFace	[optional] - An optional parameter specifying if the bottom face of the cylinder should be drawn.
	*<p/>
	*/
	public function new(material:MaterialObject3D=null, radius:Float=100, height:Float=100, segmentsW:Int=8, segmentsH:Int=6, topRadius:Float=-1, topFace:Bool=true, bottomFace:Bool=true)
	{
		super(material, new Array(), new Array(), null);

		this.segmentsW=Math.max(MIN_SEGMENTSW, segmentsW || DEFAULT_SEGMENTSW);// Defaults to 8
		this.segmentsH=Math.max(MIN_SEGMENTSH, segmentsH || DEFAULT_SEGMENTSH);// Defaults to 6
		if(radius==0)radius=DEFAULT_RADIUS;// Defaults to 100
		if(height==0)height=DEFAULT_HEIGHT;// Defaults to 100
		if(topRadius==-1)topRadius=radius;

		var scale:Float=DEFAULT_SCALE;

		buildCylinder(radius, height, topRadius, topFace, bottomFace);
	}

	private function buildCylinder(fRadius:Float, fHeight:Float, fTopRadius:Float, fTopFace:Bool, fBottomFace:Bool):Void
	{
		var matInstance:MaterialObject3D=material;
		
		var i:Float, j:Float, k:Float;

		var iHor:Float=Math.max(MIN_SEGMENTSW, this.segmentsW);
		var iVer:Float=Math.max(MIN_SEGMENTSH, this.segmentsH);
		var aVertice:Array<Dynamic>=this.geometry.vertices;
		var aFace:Array<Dynamic>=this.geometry.faces;
		var aVtc:Array<Dynamic>=new Array();
		for(j=0;j<(iVer+1);j++){ // vertical
			var fRad1:Float=Std.parseFloat(j/iVer);
			var fZ:Float=fHeight*(j/(iVer+0))-fHeight/2;//-fRadius*Math.cos(fRad1*Math.PI);
			var fRds:Float=fTopRadius+(fRadius-fTopRadius)*(1-j/(iVer));//*Math.sin(fRad1*Math.PI);
			var aRow:Array<Dynamic>=new Array();
			var oVtx:Vertex3D;
			for(i=0;i<iHor;i++){ // horizontal
				var fRad2:Float=Std.parseFloat(2*i/iHor);
				var fX:Float=fRds*Math.sin(fRad2*Math.PI);
				var fY:Float=fRds*Math.cos(fRad2*Math.PI);
				//if(!((j==0||j==iVer)&&i>0)){ // top||bottom=1 vertex
				oVtx=new Vertex3D(fY,fZ,fX);
				aVertice.push(oVtx);
				//}
				aRow.push(oVtx);
			}
			aVtc.push(aRow);
		}
		var iVerNum:Int=aVtc.length;

		var aP4uv:FloatUV, aP1uv:FloatUV, aP2uv:FloatUV, aP3uv:FloatUV;
		var aP1:Vertex3D, aP2:Vertex3D, aP3:Vertex3D, aP4:Vertex3D;

		for(j=0;j<iVerNum;j++){
			var iHorNum:Int=aVtc[j].length;
			for(i=0;i<iHorNum;i++){
				if(j>0&&i>=0){
					// select vertices
					var bEnd:Bool=i==(iHorNum-0);
					aP1=aVtc[j][bEnd?0:i];
					aP2=aVtc[j][(i==0?iHorNum:i)-1];
					aP3=aVtc[j-1][(i==0?iHorNum:i)-1];
					aP4=aVtc[j-1][bEnd?0:i];
					// uv
					var fJ0:Float=j		/ iVerNum;
					var fJ1:Float=(j-1)	/ iVerNum;
					var fI0:Float=(i+1)	/ iHorNum;
					var fI1:Float=i		/ iHorNum;
					aP4uv=new FloatUV(fI0,fJ1);
					aP1uv=new FloatUV(fI0,fJ0);
					aP2uv=new FloatUV(fI1,fJ0);
					aP3uv=new FloatUV(fI1,fJ1);
					// 2 faces
					aFace.push(new Triangle3D(this, [aP1,aP2,aP3], matInstance, [aP1uv,aP2uv,aP3uv]));
					aFace.push(new Triangle3D(this, [aP1,aP3,aP4], matInstance, [aP1uv,aP3uv,aP4uv]));
				}
			}
			if(j==0||j==(iVerNum-1)){
				for(i=0;i<(iHorNum-2);i++){
					// uv
					var iI:Int=Math.floor(i/2);
					aP1=aVtc[j][iI];
					aP2=(i%2==0)?(aVtc[j][iHorNum-2-iI]):(aVtc[j][iI+1]);
					aP3=(i%2==0)?(aVtc[j][iHorNum-1-iI]):(aVtc[j][iHorNum-2-iI]);

					var bTop:Bool=j==0;
					aP1uv=new FloatUV((bTop?1:0)+(bTop?-1:1)*(aP1.x/fRadius/2+.5), aP1.z/fRadius/2+.5);
					aP2uv=new FloatUV((bTop?1:0)+(bTop?-1:1)*(aP2.x/fRadius/2+.5), aP2.z/fRadius/2+.5);
					aP3uv=new FloatUV((bTop?1:0)+(bTop?-1:1)*(aP3.x/fRadius/2+.5), aP3.z/fRadius/2+.5);

					// face
					if(j==0){
						if(fBottomFace)aFace.push(new Triangle3D(this, [aP1, aP3, aP2], matInstance, [aP1uv, aP3uv, aP2uv]));
					}
					else {
						if(fTopFace)aFace.push(new Triangle3D(this, [aP1, aP2, aP3], matInstance, [aP1uv, aP2uv, aP3uv]));
					}
				}
			}
		}
		this.geometry.ready=true;
		
		if(Papervision3D.useRIGHTHANDED)
			this.geometry.flipFaces();
	}
}