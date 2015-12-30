package org.papervision3d.core.clipping;

import org.papervision3d.core.geom.renderables.Triangle3D;
import org.papervision3d.core.math.util.ClassificationUtil;
import org.papervision3d.core.proto.MaterialObject3D;
import org.papervision3d.core.render.data.RenderSessionData;
import org.papervision3d.objects.DisplayObject3D;

class DefaultClipping
{
	public function new()
	{
	}
	
	
	
	public function reset(renderSessionData:RenderSessionData):Void{
		
	}
	
	public function setDisplayObject(object:DisplayObject3D, renderSessionData:RenderSessionData):Void{
		return;
	}
	
	public function testFace(triangle:Triangle3D, object:DisplayObject3D, renderSessionData:RenderSessionData):Bool{
		return false;
	}
	
	public function clipFace(triangle:Triangle3D, object:DisplayObject3D, material:MaterialObject3D, renderSessionData:RenderSessionData, outputArray:Array):Float{
		return 0;
	}

}