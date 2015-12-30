package org.papervision3d.core.render.filter {
import org.papervision3d.core.render.command.RenderFog;
import org.papervision3d.core.render.command.RenderableListItem;
import org.papervision3d.materials.special.FogMaterial;
import org.papervision3d.objects.DisplayObject3D;
import org.papervision3d.view.layer.ViewportLayer;	

class FogFilter extends BasicRenderFilter
{
	
	private var _maxDepth:Float;
	private function set_maxDepth(value:Float):Void{
		_maxDepth=value;
		if(_maxDepth<_minDepth)
			_minDepth=_maxDepth-1;
	}
	
	public var maxDepth(get_maxDepth, set_maxDepth):Float;
 	private function get_maxDepth():Float{
		return _maxDepth;
	}
	
	private var _minDepth:Float;
	private function set_minDepth(value:Float):Void{
		_minDepth=value;
		if(_maxDepth<_minDepth)
			_maxDepth=minDepth+1;
	}
	
	public var minDepth(get_minDepth, set_minDepth):Float;
 	private function get_minDepth():Float{
		return _minDepth;
	}
	
	public var segments:Float;
	public var material:FogMaterial;
	public var viewportLayer:ViewportLayer;
	private var do3ds:Array<Dynamic>=new Array();
	public function new(material:FogMaterial, segments:Int=8, minDepth:Float=200, maxDepth:Float=4000, useViewportLayer:ViewportLayer=null)
	{
		super();
		this.material=material;
		this.segments=segments;
		this.minDepth=minDepth;
		this.maxDepth=maxDepth;
		this.viewportLayer=useViewportLayer;
		
		for(i in 0...segments){
			do3ds[i]=new DisplayObject3D();
		}
	}
		
	public override function filter(array:Array):Int{
		
		var segOffset:Float=(_maxDepth-_minDepth)/segments;
		var segDepth:Float=_minDepth;
		
		var alpha:Float=1-(segments/100);
		//var alphaOffset:Float=alpha/segments;

		
		for(var i:Int=array.length-1;i>=0;i--){
			if(array[i].screenZ>=maxDepth)
				removeRenderItem(array, i);
		} 		
			
		for(ii in 0...segments){
			
			if(this.viewportLayer){
				
				array.push(new RenderFog(material,((alpha/segments)*ii+((ii)/100)), segDepth, do3ds[ii]));
				var vpl:ViewportLayer=new ViewportLayer(null, do3ds[ii], true);
				vpl.forceDepth=true;
				vpl.screenDepth=segDepth;
				viewportLayer.addLayer(vpl);
			}else{
				array.push(new RenderFog(material,((alpha/segments)*ii+((ii)/100)), segDepth));
			}
				
			segDepth +=segOffset;			
		}
		
					
		return 0;
		
	}
	
	private function visibleDepth(element:RenderableListItem, index:Int, arr:Array):Bool {
		return(element.screenZ<_maxDepth);
	}
	
	private function removeRenderItem(ar:Array, index:Float):Void{
		ar=ar.splice(index, 1);
	}
	
	
}