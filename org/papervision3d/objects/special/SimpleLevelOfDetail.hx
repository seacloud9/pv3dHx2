package org.papervision3d.objects.special {
import org.papervision3d.core.render.data.RenderSessionData;
import org.papervision3d.objects.DisplayObject3D;	

class SimpleLevelOfDetail extends DisplayObject3D
{
	public var currentObject:DisplayObject3D;
	public var objects:Array<Dynamic>;
	public var minDepth:Float;
	public var maxDepth:Float;
	public var distances:Array<Dynamic>;
	
	public function new(objects:Array, minDepth:Float=1000, maxDepth:Float=10000, distances:Array<Dynamic>=null)
	{
		this.objects=objects;
		this.minDepth=minDepth;
		this.maxDepth=maxDepth;
		this.distances=distances;

		super();
		
		addChild(objects[0]);
		currentObject=objects[0];
	}
	
	public function updateLoD(index:Float=-1):Void{
		
		
		var objCount:Float=objects.length;
		var depth:Float=this.screenZ - minDepth;
		var modelIndex:Float=0;
		
		if(index==-1){

			if(distances==null){
				if(this.screenZ<minDepth){
					modelIndex=0;
				}else if(this.screenZ>=maxDepth){
					modelIndex=objects.length-1;
				}else{
					var segSize:Float=(maxDepth-minDepth)/objCount;
					modelIndex=Std.int(depth/segSize);
					
				}
			}else{
				//use the distance array!
				
				for(i in 0...distances.length){
					if(this.screenZ<distances[i]){
						break;
					}
					modelIndex=distances[i];
				}
				
				modelIndex=Math.min(objCount-1, modelIndex);
				
			}
			
		
		}else{
			modelIndex=index;
		}
		
		if(objects[modelIndex]==currentObject)
			return;
		
		removeChild(currentObject);
		currentObject=objects[modelIndex];
		addChild(currentObject);
			
	}
	
	public override function project(parent:DisplayObject3D, renderSessionData:RenderSessionData):Float{
		updateLoD();
		return super.project(parent, renderSessionData);
	}

	
}