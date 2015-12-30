package org.papervision3d.view.layer {
import flash.display.Graphics;
import flash.display.Sprite;
import flash.utils.Dictionary;

import org.papervision3d.core.log.PaperLogger;
import org.papervision3d.core.ns.pv3dview;
import org.papervision3d.core.render.command.RenderableListItem;
import org.papervision3d.objects.DisplayObject3D;
import org.papervision3d.view.Viewport3D;
import org.papervision3d.view.layer.util.ViewportLayerSortMode;	
/**
 * @Author Ralph Hauwert
 */
class ViewportLayer extends Sprite
{
	use namespace pv3dview;
	
	public var childLayers			:Array<Dynamic>;
	public var layers				:Dictionary=new Dictionary(true);
	public var displayObject3D		:DisplayObject3D;
	public var displayObjects		:Dictionary=new Dictionary(true);
	
	public var layerIndex			:Float;
	public var forceDepth			:Bool=false;
	public var screenDepth			:Float=0;
	public var originDepth			:Float=0;
	public var weight				:Float=0;
	public var sortMode				:String=ViewportLayerSortMode.Z_SORT;
	public var dynamicLayer			:Bool=false;
	public var graphicsChannel		:Graphics;
		private var viewport			:Viewport3D;		
	public function new(viewport:Viewport3D, do3d:DisplayObject3D, isDynamic:Bool=false)
	{
		super();
		this.viewport=viewport;
		this.displayObject3D=do3d;
		this.dynamicLayer=isDynamic;
		this.graphicsChannel=this.graphics;
	
		if(isDynamic){
			this.filters=do3d.filters;
			this.blendMode=do3d.blendMode;
			this.alpha=do3d.alpha;
		}
		
		if(do3d){
			addDisplayObject3D(do3d);
			do3d.container=this;
		}
		
		init();
	}
	
	public function addDisplayObject3D(do3d:DisplayObject3D, recurse:Bool=false):Void{
		
		if(!do3d)return;
		
		displayObjects[do3d]=do3d;
		dispatchEvent(new ViewportLayerEvent(ViewportLayerEvent.CHILD_ADDED, do3d, this));
		
		if(recurse)
			do3d.addChildrenToLayer(do3d, this);
	}
	
	public function removeDisplayObject3D(do3d:DisplayObject3D):Void{
		displayObjects[do3d]=null;
		dispatchEvent(new ViewportLayerEvent(ViewportLayerEvent.CHILD_REMOVED, do3d, this));
	}
	
	public function hasDisplayObject3D(do3d:DisplayObject3D):Bool{
		return(displayObjects[do3d] !=null);
	}
	
	private function init():Void
	{
		childLayers=new Array();
	}
	
	public function getChildLayer(do3d:DisplayObject3D, createNew:Bool=true, recurse:Bool=false):ViewportLayer{
		
		do3d=do3d.parentContainer?do3d.parentContainer:do3d;	
		
		/* var index:Float=childLayerIndex(do3d);
		
		if(index>-1)
			return childLayers[index];
		
		for(var vpl:ViewportLayer in childLayers){
			var tmpLayer:ViewportLayer=vpl.getChildLayer(do3d, false);
			if(tmpLayer)
				return tmpLayer;
		}	
		 */
		 
		if(layers[do3d]){
			return layers[do3d];
		}
			
		 
		//no layer found=return a new one
		if(createNew)
			return getChildLayerFor(do3d, recurse);
		else
			return null;
	}
	
	private function getChildLayerFor(displayObject3D:DisplayObject3D, recurse:Bool=false):ViewportLayer
	{
		
		if(displayObject3D){
			var vpl:ViewportLayer=new ViewportLayer(viewport,displayObject3D, displayObject3D.useOwnContainer);
			addLayer(vpl);

			if(recurse)
				displayObject3D.addChildrenToLayer(displayObject3D, vpl);
			
			return vpl;
		}else{
			PaperLogger.warning("Needs to be a do3d");
		}
		return null;
	}
	
	public function childLayerIndex(do3d:DisplayObject3D):Float{
		
		do3d=do3d.parentContainer?do3d.parentContainer:do3d;
		
		for(i in 0...childLayers.length){
			if(childLayers[i].hasDisplayObject3D(do3d)){
				return i;
			}
		}
		return -1;
	}
	
	public function addLayer(vpl:ViewportLayer):Void{
		
		var do3d:DisplayObject3D;
					if(childLayers.indexOf(vpl)!=-1)			{								PaperLogger.warning("Child layer already exists in ViewportLayer");				return;						}
		childLayers.push(vpl);
		addChild(vpl);
		
		vpl.addEventListener(ViewportLayerEvent.CHILD_ADDED, onChildAdded);
		vpl.addEventListener(ViewportLayerEvent.CHILD_REMOVED, onChildRemoved);
		
		for(do3d in vpl.displayObjects){
			linkChild(do3d, vpl);
		}
		
		for(var v:ViewportLayer in vpl.layers){
			for(do3d in v.displayObjects){
				linkChild(do3d, v);
			}
		}
	}
	
	private function linkChild(do3d:DisplayObject3D, vpl:ViewportLayer, e:ViewportLayerEvent=null):Void{
		
		layers[do3d]=vpl;
		dispatchEvent(new ViewportLayerEvent(ViewportLayerEvent.CHILD_ADDED, do3d, vpl));
		
	}
	
	private function unlinkChild(do3d:DisplayObject3D, e:ViewportLayerEvent=null):Void{
		layers[do3d ]=null;
		dispatchEvent(new ViewportLayerEvent(ViewportLayerEvent.CHILD_REMOVED, do3d));
	}
	
	private function onChildAdded(e:ViewportLayerEvent):Void{
		if(e.do3d){
			linkChild(e.do3d, e.layer, e);
		}
	}
	
	private function onChildRemoved(e:ViewportLayerEvent):Void{
		if(e.do3d){
			unlinkChild(e.do3d, e);
		}
	}
	
	public function updateBeforeRender():Void{
		clear();
		for(var vpl:ViewportLayer in childLayers){
			vpl.updateBeforeRender();
		}
	}
	
	public function updateAfterRender():Void{
		for(var vpl:ViewportLayer in childLayers){
			vpl.updateAfterRender();
		}
	}
	
	public function removeLayer(vpl:ViewportLayer):Void{
		
		var index:Int=getChildIndex(vpl);
		if(index>-1){
			removeLayerAt(index);
		}else{
			PaperLogger.error("Layer not found for removal.");
		}
	}
	
	public function removeLayerAt(index:Float):Void{
		
		for(var do3d:DisplayObject3D in childLayers[index].displayObjects){
			unlinkChild(do3d);
		}
		removeChild(childLayers[index]);
		childLayers.splice(index, 1);
		
	}
	
	public function getLayerObjects(ar:Array<Dynamic>=null):Array{
	
		if(!ar)
			ar=new Array();

		for(var do3d:DisplayObject3D in this.displayObjects){
			if(do3d){
				ar.push(do3d);
			}
		}
		
		for(var vpl:ViewportLayer in childLayers){
			vpl.getLayerObjects(ar);
		}
		
		
		
		return ar;
		
	}
	
	
	
	public function clear():Void
	{
			
		/* var vpl:ViewportLayer;
		for(vpl in childLayers){
			
			vpl.clear();
		} */
		graphicsChannel.clear();
		reset();
	}
	
	private function reset():Void{
		
		if(!forceDepth)
		{
			screenDepth=0;
			originDepth=0;
		}
			
		this.weight=0;
		
	}
	
	public function sortChildLayers():Void		{
		switch(sortMode)
		{
			case ViewportLayerSortMode.Z_SORT:
				childLayers.sortOn("screenDepth", Array.DESCENDING | Array.NUMERIC);
				break;
			
			case ViewportLayerSortMode.INDEX_SORT:
				childLayers.sortOn("layerIndex", Array.NUMERIC);
				break;
			
			case ViewportLayerSortMode.ORIGIN_SORT:
				childLayers.sortOn([ "originDepth", "screenDepth" ] , [ Array.DESCENDING | Array.NUMERIC, Array.DESCENDING | Array.NUMERIC ]);
				break;
		}
				
		orderLayers();
	}
	
	private function orderLayers():Void{
		for(i in 0...childLayers.length)
		{
			var layer:ViewportLayer=childLayers[i];
			if(this.getChildIndex(layer)!=i)this.setChildIndex(layer, i);
			layer.sortChildLayers();
		}
	}
	
	public function processRenderItem(rc:RenderableListItem):Void{
		if(!forceDepth)			{				if(!isNaN(rc.screenZ))				{				
				this.screenDepth +=rc.screenZ;					if(rc.instance)					{
					this.originDepth +=rc.instance.world.n34;
					this.originDepth +=rc.instance.screen.z;					}
				this.weight++;
							}			}		}
	
	public function updateInfo():Void{
		
		//this.screenDepth /=this.weight;
		
		for(var vpl:ViewportLayer in childLayers){
			vpl.updateInfo();
			if(!forceDepth){					// screenDepth is sometimes NaN if the child objects are invisible or empty					if(!isNaN(vpl.screenDepth))					{						this.weight +=vpl.weight;
					this.screenDepth +=(vpl.screenDepth*vpl.weight);
					this.originDepth +=(vpl.originDepth*vpl.weight);					}				
			}
		}
		
		if(!forceDepth)
		{
			this.screenDepth /=this.weight;
			this.originDepth /=this.weight;
		}		
		
	}
	
	public function removeAllLayers():Void{
		for(var i:Int=childLayers.length-1;i>=0;i--){
			removeLayerAt(i);
		}
	}
}