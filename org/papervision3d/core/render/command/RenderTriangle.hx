package org.papervision3d.core.render.command;


/**
 * @Author Ralph Hauwert
 */
import flash.display.BitmapData;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.geom.Point;
import flash.geom.Rectangle;

import org.papervision3d.core.geom.renderables.Triangle3D;
import org.papervision3d.core.geom.renderables.Vertex3DInstance;
import org.papervision3d.core.math.Matrix3D;
import org.papervision3d.core.math.Number3D;
import org.papervision3d.core.math.NumberUV;
import org.papervision3d.core.proto.MaterialObject3D;
import org.papervision3d.core.render.data.RenderHitData;
import org.papervision3d.core.render.data.RenderSessionData;
import org.papervision3d.core.render.draw.ITriangleDrawer;
import org.papervision3d.materials.BitmapMaterial;
import org.papervision3d.materials.MovieMaterial;	

class RenderTriangle extends RenderableListItem implements IRenderListItem
{
	protected static var resBA:Vertex3DInstance=new Vertex3DInstance();
	protected static var resPA:Vertex3DInstance=new Vertex3DInstance();
	protected static var resRA:Vertex3DInstance=new Vertex3DInstance();
	protected static var vPoint:Vertex3DInstance=new Vertex3DInstance();
	
	private var position:Float3D=new Float3D();
	
	public var triangle:Triangle3D;
	public var container:Sprite;
	public var renderer:ITriangleDrawer;
	public var renderMat:MaterialObject3D;
	
	/*
		Drawing Variables
	*/
	public var v0:Vertex3DInstance;
	public var v1:Vertex3DInstance;
	public var v2:Vertex3DInstance;
	
	public var uv0:FloatUV;
	public var uv1:FloatUV;
	public var uv2:FloatUV;
	
	//for creating new RT from store.  See TriangleMesh3D createDrawTriangle
	public var create:Function;
	
	public function new(triangle:Triangle3D):Void
	{
		this.triangle=triangle;
		this.instance=triangle.instance;
		renderableInstance=triangle;
		renderable=Triangle3D;
		
		this.v0=triangle.v0.vertex3DInstance;
		this.v1=triangle.v1.vertex3DInstance;
		this.v2=triangle.v2.vertex3DInstance;
		
		this.uv0=triangle.uv0;
		this.uv1=triangle.uv1;
		this.uv2=triangle.uv2;
		
		this.renderer=triangle.material;
		
		update();
	}
	
	
	
	override public function render(renderSessionData:RenderSessionData, graphics:Graphics):Void
	{
					
		renderer.drawTriangle(this, graphics, renderSessionData);

	}
	
	private var vPointL:Vertex3DInstance;
	private var vx0:Vertex3DInstance;
	private var vx1:Vertex3DInstance;
	private var vx2:Vertex3DInstance;
	
	override public function hitTestPoint2D(point:Point, renderhitData:RenderHitData):RenderHitData
	{
		renderMat=triangle.material;
		if(!renderMat)renderMat=triangle.instance.material;
		
		if(renderMat && renderMat.interactive){
			vPointL=RenderTriangle.vPoint;
			vPointL.x=point.x;
			vPointL.y=point.y;
			vx0=triangle.v0.vertex3DInstance;
			vx1=triangle.v1.vertex3DInstance;
			vx2=triangle.v2.vertex3DInstance;
			if(sameSide(vPointL,vx0,vx1,vx2)){
				if(sameSide(vPointL,vx1,vx0,vx2)){
					if(sameSide(vPointL,vx2,vx0,vx1)){
						return deepHitTest(triangle, vPointL, renderhitData);
					}
				}
			}
		}
		return renderhitData;
	}
	
	public function sameSide(point:Vertex3DInstance, ref:Vertex3DInstance, a:Vertex3DInstance, b:Vertex3DInstance):Bool
	{
		Vertex3DInstance.subTo(b,a,resBA);
		Vertex3DInstance.subTo(point,a,resPA);
		Vertex3DInstance.subTo(ref, a, resRA);
		return Vertex3DInstance.cross(resBA, resPA)*Vertex3DInstance.cross(resBA, resRA)>=0;
	}
	
	private function deepHitTest(face:Triangle3D, vPoint:Vertex3DInstance, rhd:RenderHitData):RenderHitData
	{
		var v0:Vertex3DInstance=face.v0.vertex3DInstance;
		var v1:Vertex3DInstance=face.v1.vertex3DInstance;
		var v2:Vertex3DInstance=face.v2.vertex3DInstance;
		
		var v0_x:Float=v2.x - v0.x;
		var v0_y:Float=v2.y - v0.y;
		var v1_x:Float=v1.x - v0.x;
		var v1_y:Float=v1.y - v0.y;
		var v2_x:Float=vPoint.x - v0.x;
		var v2_y:Float=vPoint.y - v0.y;
		var dot00:Float=v0_x * v0_x + v0_y * v0_y;
		var dot01:Float=v0_x * v1_x + v0_y * v1_y;
		var dot02:Float=v0_x * v2_x + v0_y * v2_y;
		var dot11:Float=v1_x * v1_x + v1_y * v1_y;
		var dot12:Float=v1_x * v2_x + v1_y * v2_y;
		
		var invDenom:Float=1 /(dot00 * dot11 - dot01 * dot01);
		var u:Float=(dot11 * dot02 - dot01 * dot12)* invDenom;
		var v:Float=(dot00 * dot12 - dot01 * dot02)* invDenom;
		
		var rv0_x:Float=face.v2.x - face.v0.x;
		var rv0_y:Float=face.v2.y - face.v0.y;
		var rv0_z:Float=face.v2.z - face.v0.z;
		var rv1_x:Float=face.v1.x - face.v0.x;
		var rv1_y:Float=face.v1.y - face.v0.y;
		var rv1_z:Float=face.v1.z - face.v0.z;
		
		var hx:Float=face.v0.x + rv0_x*u + rv1_x*v;
		var hy:Float=face.v0.y + rv0_y*u + rv1_y*v;
		var hz:Float=face.v0.z + rv0_z*u + rv1_z*v;
		
		//From Interactive utils
		var uv:Array<Dynamic>=face.uv;
		var uu0:Float=uv[0].u;
		var uu1:Float=uv[1].u;
		var uu2:Float=uv[2].u;
		var uv0:Float=uv[0].v;
		var uv1:Float=uv[1].v;
		var uv2:Float=uv[2].v;
			
		var v_x:Float=(uu1 - uu0)* v +(uu2 - uu0)* u + uu0;
		var v_y:Float=(uv1 - uv0)* v +(uv2 - uv0)* u + uv0;
		
		if(triangle.material)
			renderMat=face.material;
		else
			renderMat=face.instance.material;
		
		var bitmap:BitmapData=renderMat.bitmap;
		var width:Float=1;
		var height:Float=1;
		var dx:Float=0;
		var dy:Float=0;

		// MovieMaterial rect
		if(Std.is(renderMat, MovieMaterial))
		{
			var movieRenderMat:MovieMaterial=cast(renderMat, MovieMaterial);
			var rect:Rectangle=movieRenderMat.rect;
			if(rect)
			{
				dx=rect.x;
				dy=rect.y;
				width=rect.width;
				height=rect.height;
			}
		}
		else if(bitmap)
		{
			width=BitmapMaterial.AUTO_MIP_MAPPING ? renderMat.widthOffset:bitmap.width;
			height=BitmapMaterial.AUTO_MIP_MAPPING ? renderMat.heightOffset:bitmap.height;
		}
		//end from Interactive utils

		rhd.displayObject3D=face.instance;
		rhd.material=renderMat;
		rhd.renderable=face;
		rhd.hasHit=true;
		position.x=hx;
		position.y=hy;
		position.z=hz;
		Matrix3D.multiplyVector(face.instance.world, position);
		
		rhd.x=position.x;//hx;
		rhd.y=position.y;//hy;
		rhd.z=position.z;//hz;

		rhd.u=v_x * width + dx;
		rhd.v=height - v_y * height + dy;

		return rhd;
	}

	public override function update():Void{
		if(v0.x>v1.x){
			if(v0.x>v2.x)maxX=v0.x;
			else maxX=v2.x;
		} else {
			if(v1.x>v2.x)maxX=v1.x;
			else maxX=v2.x;
		}
		
		if(v0.x<v1.x){
			if(v0.x<v2.x)minX=v0.x;
			else minX=v2.x;
		} else {
			if(v1.x<v2.x)minX=v1.x;
			else minX=v2.x;
		}
		
		if(v0.y>v1.y){
			if(v0.y>v2.y)maxY=v0.y;
			else maxY=v2.y;
		} else {
			if(v1.y>v2.y)maxY=v1.y;
			else maxY=v2.y;
		}
		
		if(v0.y<v1.y){
			if(v0.y<v2.y)minY=v0.y;
			else minY=v2.y;
		} else {
			if(v1.y<v2.y)minY=v1.y;
			else minY=v2.y;
		}
		
		if(v0.z>v1.z){
			if(v0.z>v2.z)maxZ=v0.z;
			else maxZ=v2.z;
		} else {
			if(v1.z>v2.z)maxZ=v1.z;
			else maxZ=v2.z;
		}
		
		if(v0.z<v1.z){
			if(v0.z<v2.z)minZ=v0.z;
			else minZ=v2.z;
		} else {
			if(v1.z<v2.z)minZ=v1.z;
			else minZ=v2.z;
		}
		
		screenZ=(v0.z + v1.z + v2.z)/ 3;
		area=0.5 *(v0.x*(v2.y - v1.y)+ v1.x*(v0.y - v2.y)+ v2.x*(v1.y - v0.y));
		
	}
	
	public function fivepointcut(v0:Vertex3DInstance, v01:Vertex3DInstance, v1:Vertex3DInstance, v12:Vertex3DInstance, v2:Vertex3DInstance, uv0:FloatUV, uv01:FloatUV, uv1:FloatUV, uv12:FloatUV, uv2:FloatUV):Array
	{
		if(v0.distanceSqr(v12)<v01.distanceSqr(v2))
		{
			return [
				create(renderableInstance, renderer,  v0, v01, v12,  uv0, uv01, uv12),
				create(renderableInstance, renderer, v01,  v1, v12, uv01,  uv1, uv12),
				create(renderableInstance, renderer,  v0, v12 , v2,  uv0, uv12, uv2)];
		}
		else
		{
			return [
				create(renderableInstance, renderer,  v0, v01,  v2,  uv0, uv01, uv2),
				create(renderableInstance, renderer, v01,  v1, v12, uv01,  uv1, uv12),
				create(renderableInstance, renderer, v01, v12,  v2, uv01, uv12, uv2)];
		}
	}	
	
	
	
	public override final function getZ(x:Float, y:Float, focus:Float):Float
	{
		
		ax=v0.x;
		ay=v0.y;
		az=v0.z;
		bx=v1.x;
		by=v1.y;
		bz=v1.z;
		cx=v2.x;
		cy=v2.y;
		cz=v2.z;

		if((ax==x)&&(ay==y))
			return az;

		if((bx==x)&&(by==y))
			return bz;

		if((cx==x)&&(cy==y))
			return cz;

		azf=az / focus;
		bzf=bz / focus;
		czf=cz / focus;

		faz=1 + azf;
		fbz=1 + bzf;
		fcz=1 + czf;

		axf=ax*faz - x*azf;
		bxf=bx*fbz - x*bzf;
		cxf=cx*fcz - x*czf;
		ayf=ay*faz - y*azf;
		byf=by*fbz - y*bzf;
		cyf=cy*fcz - y*czf;

		det=axf*(byf - cyf)+ bxf*(cyf - ayf)+ cxf*(ayf - byf);
		da=x*(byf - cyf)+ bxf*(cyf - y)+ cxf*(y - byf);
		db=axf*(y - cyf)+ x*(cyf - ayf)+ cxf*(ayf - y);
		dc=axf*(byf - y)+ bxf*(y - ayf)+ x*(ayf - byf);

		return(da*az + db*bz + dc*cz)/ det;
	}
	
	public override final function quarter(focus:Float):Array
	{
		if(area<20)
			return null;

		v01=Vertex3DInstance.median(v0, v1, focus);
		v12=Vertex3DInstance.median(v1, v2, focus);
		v20=Vertex3DInstance.median(v2, v0, focus);
		uv01=NumberUV.median(uv0, uv1);
		uv12=NumberUV.median(uv1, uv2);
		uv20=NumberUV.median(uv2, uv0);

		return [
			create(renderableInstance, renderer, v0, v01, v20, uv0, uv01, uv20),
			create(renderableInstance, renderer, v1, v12, v01, uv1, uv12, uv01),
			create(renderableInstance, renderer, v2, v20, v12, uv2, uv20, uv12),
			create(renderableInstance, renderer, v01, v12, v20, uv01, uv12, uv20)
		];
	}
	
	/*
	Don't touch these - needed for quad
	*/
	
	private var ax:Float;
	private var ay:Float;
	private var az:Float;
	private var bx:Float;
	private var by:Float;
	private var bz:Float;
	private var cx:Float;
	private var cy:Float;
	private var cz:Float;
	private var azf:Float;
	private var bzf:Float;
	private var czf:Float;
	private var faz:Float;
	private var fbz:Float;
	private var fcz:Float;
	private var axf:Float;
	private var bxf:Float;
	private var cxf:Float;
	private var ayf:Float;
	private var byf:Float;
	private var cyf:Float;
	private var det:Float;
	private var da:Float;
	private var db:Float;
	private var dc:Float;
	private var au:Float;
	private var av:Float;
	private var bu:Float;
	private var bv:Float;
	private var cu:Float;
	private var cv:Float;

	private var v01:Vertex3DInstance;
	private var v12:Vertex3DInstance;
	private var v20:Vertex3DInstance;
	private var uv01:FloatUV;
	private var uv12:FloatUV;
	private var uv20:FloatUV;
	
}