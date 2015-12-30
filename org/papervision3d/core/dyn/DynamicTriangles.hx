package org.papervision3d.core.dyn;

import org.papervision3d.core.geom.renderables.Triangle3D;
import org.papervision3d.core.geom.renderables.Vertex3D;
import org.papervision3d.core.math.NumberUV;
import org.papervision3d.core.proto.MaterialObject3D;
import org.papervision3d.materials.BitmapMaterial;
import org.papervision3d.materials.special.CompositeMaterial;
import org.papervision3d.objects.DisplayObject3D;

class DynamicTriangles
{
	private static inline var GROW_SIZE:Int=300;
	private static inline var INIT_SIZE:Int=100;

	private var triangleCounter:Int;
	private var trianglePool:Array<Dynamic>;
	
	public function new()
	{
		init();
	}
	
	private static function init():Void
	{
		trianglePool=new Array(INIT_SIZE);
		var i:Int=INIT_SIZE;
		while(--i>-1){
			trianglePool[ i ]=new Triangle3D(null, null, null, null);
		}
		triangleCounter=INIT_SIZE;
	}
	
	public function getTriangle(object:DisplayObject3D=null, m:MaterialObject3D=null,v0:Vertex3D=null,v1:Vertex3D=null,v2:Vertex3D=null,uv0:FloatUV=null,uv1:FloatUV=null, uv2:FloatUV=null):Triangle3D
	{
		if(triangleCounter==0){
			var i:Int=GROW_SIZE;
			while(--i>-1){
				trianglePool.unshift(new Triangle3D(null,null,null,null));
			}
			triangleCounter=GROW_SIZE;
			return getTriangle(object, m,v0,v1,v2,uv0,uv1,uv2);
		}else{
			var triangle:Triangle3D=Triangle3D(trianglePool[--triangleCounter]);
			if(triangle.material){
				
				if(triangle.material is BitmapMaterial && BitmapMaterial(triangle.material).uvMatrices)
				{
					BitmapMaterial(triangle.material).uvMatrices[triangle.renderCommand]=null;
				}
				
				if(triangle.material is CompositeMaterial)
				{
					for(var mat:MaterialObject3D in CompositeMaterial(triangle.material).materials)
					{
						if(Std.is(mat, BitmapMaterial) && BitmapMaterial(mat).uvMatrices)
						{
							BitmapMaterial(mat).uvMatrices[triangle.renderCommand]=null;
						}
					}
				}
			}

			triangle.instance=object;
			triangle.vertices=[v0, v1, v2];
			triangle.uv=[uv0, uv1, uv2];
			triangle.updateVertices();
			triangle.createNormal();
			triangle.material=m;

			return triangle;
		}
	}
	
	public function releaseAll():Void
	{
		returnAllTriangles();
	}
	
	public function returnTriangle(triangle:Triangle3D):Void
	{
		trianglePool[triangleCounter++]=triangle;
	}
	
	public function returnAllTriangles():Void
	{
		triangleCounter=trianglePool.length;
	}
}