/**
* @author Pierre Lepers
* @author De'Angelo Richardson
* @author John Grden
* 
* NOTES:
* 	Special thanks to Blackpawn for this post:
*   http://www.blackpawn.com/texts/pointinpoly/default.html
* 
* 	And Pierre Lepers / Away3D for providing the foundational UVatPoint and getCoordAtPoint methods.  We're not sure who came out with them first, but wanted
* 	to thank them both just the same.
* 
* 	These rock!!
* @version 1.0
*/
package org.papervision3d.core.utils {
import flash.display.BitmapData;

import org.papervision3d.core.geom.renderables.Triangle3D;
import org.papervision3d.core.geom.renderables.Vertex3D;
import org.papervision3d.core.proto.MaterialObject3D;
import org.papervision3d.materials.BitmapMaterial;
import org.papervision3d.objects.DisplayObject3D;	

/**
 * InteractiveUtils are used in conjunction with the ISM to resolve a face's mouse Interaction and coordinates back to 2D screen space
 * 
 * 
 */	
class InteractiveUtils 
{
	public static function UVatPoint(face3d:Triangle3D, x:Float, y:Float):Dynamic 
	{	
		
		var v0:Vertex3D=face3d.v0;
		var v1:Vertex3D=face3d.v1;
		var v2:Vertex3D=face3d.v2;
		
		var v0Dx:Float=v0.vertex3DInstance.x;
		var v0Dy:Float=v0.vertex3DInstance.y;
		var v1Dx:Float=v1.vertex3DInstance.x;
		var v1Dy:Float=v1.vertex3DInstance.y;
		var v2Dx:Float=v2.vertex3DInstance.x;
		var v2Dy:Float=v2.vertex3DInstance.y;
		
		var v0_x:Float=v2Dx - v0Dx;
		var v0_y:Float=v2Dy - v0Dy;
		var v1_x:Float=v1Dx - v0Dx;
		var v1_y:Float=v1Dy - v0Dy;
		var v2_x:Float=x - v0Dx;
		var v2_y:Float=y - v0Dy;
			
		var dot00:Float=v0_x * v0_x + v0_y * v0_y;
		var dot01:Float=v0_x * v1_x + v0_y * v1_y;
		var dot02:Float=v0_x * v2_x + v0_y * v2_y;
		var dot11:Float=v1_x * v1_x + v1_y * v1_y;
		var dot12:Float=v1_x * v2_x + v1_y * v2_y;
			
		var invDenom:Float=1 /(dot00 * dot11 - dot01 * dot01);
		var u:Float=(dot11 * dot02 - dot01 * dot12)* invDenom;
		var v:Float=(dot00 * dot12 - dot01 * dot02)* invDenom;
	   
		return { u:u, v:v };
	}
	
	public static function getCoordAtPoint(face3d:Triangle3D, x:Float, y:Float):Vertex3D
	{	
		var rUV:Dynamic=UVatPoint(face3d, x, y);
		
		var v0x:Float=face3d.v0.x;
		var v0y:Float=face3d.v0.y;
		var v0z:Float=face3d.v0.z;
		var v1x:Float=face3d.v1.x;
		var v1y:Float=face3d.v1.y;
		var v1z:Float=face3d.v1.z;
		var v2x:Float=face3d.v2.x;
		var v2y:Float=face3d.v2.y;
		var v2z:Float=face3d.v2.z;
		
		var u:Float=rUV.u;
		var v:Float=rUV.v;
			
		var rX:Float=v0x +(v1x - v0x)* v +(v2x - v0x)* u;
		var rY:Float=v0y +(v1y - v0y)* v +(v2y - v0y)* u;
		var rZ:Float=v0z +(v1z - v0z)* v +(v2z - v0z)* u;
			
		return new Vertex3D(rX,rY,rZ);
	}
	
	public static function getMapCoordAtPointDO3D(displayObject:DisplayObject3D, x:Float, y:Float):Dynamic
	{
		var face:Triangle3D=displayObject.geometry.faces[0];
		return getMapCoordAtPoint(face, x, y);
	}
	
	public static function getMapCoordAtPoint(face3d:Triangle3D, x:Float, y:Float):Dynamic 
	{
		
		var uv:Array<Dynamic>=face3d.uv;
		
		var rUV:Dynamic=UVatPoint(face3d, x, y);
		var u:Float=rUV.u;
		var v:Float=rUV.v;
		
		var u0:Float=uv[0].u;
		var u1:Float=uv[1].u;
		var u2:Float=uv[2].u;
		var v0:Float=uv[0].v;
		var v1:Float=uv[1].v;
		var v2:Float=uv[2].v;
			
		var v_x:Float=(u1 - u0)* v +(u2 - u0)* u + u0;
		var v_y:Float=(v1 - v0)* v +(v2 - v0)* u + v0;

		var material:MaterialObject3D=face3d.instance.material;
		var bitmap:BitmapData=material.bitmap;
		var width:Float=1;
		var height:Float=1;
		if(bitmap)
		{
			width=BitmapMaterial.AUTO_MIP_MAPPING ? material.widthOffset:bitmap.width;
			height=BitmapMaterial.AUTO_MIP_MAPPING ? material.heightOffset:bitmap.height;
		}
			
		return { x:v_x * width, y:height - v_y * height };
	}
}