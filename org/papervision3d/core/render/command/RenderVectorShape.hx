package org.papervision3d.core.render.command {	import org.papervision3d.core.geom.renderables.VectorShapeRenderable;	import org.papervision3d.core.render.command.IRenderListItem;	import org.papervision3d.core.render.command.RenderableListItem;	import org.papervision3d.core.render.data.RenderHitData;	import org.papervision3d.core.render.data.RenderSessionData;	import org.papervision3d.materials.special.VectorShapeMaterial;	import org.papervision3d.objects.special.VectorShape3D;	import org.papervision3d.objects.special.commands.IVectorShape;		import flash.display.Graphics;	import flash.geom.Point;		/**	 * @author Mark Barcinski	 */	class RenderVectorShape extends RenderableListItem implements IRenderListItem {		public var vectorShape:VectorShape3D;		public var renderer:VectorShapeMaterial;				public function new(vectorShape:VectorShape3D){			this.vectorShape=vectorShape;			this.renderable=VectorShapeRenderable;			this.renderableInstance=new VectorShapeRenderable(vectorShape, this);			super();		}				public override function render(renderSessionData:RenderSessionData , graphics:Graphics):Void {								renderer.drawShape(vectorShape, graphics, renderSessionData);		}				override public function hitTestPoint2D(point:Point, renderhitData:RenderHitData):RenderHitData		{			if(!renderer.interactive)return renderhitData;									var hitTestInstance:VectorShapeHitTest=VectorShapeHitTest.instance;			var g:Graphics=hitTestInstance.graphics;			g.clear();			g.beginFill(0xff0000);						var prevDrawn:Bool=false;			for(i in 0...vectorShape.graphicsCommands.length){				prevDrawn=IVectorShape(vectorShape.graphicsCommands[i]).draw(g , prevDrawn);				}						if(hitTestInstance.hitTestPoint(point.x, point.y, true)){				renderhitData.displayObject3D=vectorShape;				renderhitData.material=renderer;				//renderhitData.renderable=IRenderable(renderable);				renderhitData.hasHit=true;								//TODO UPDATE 3D hit point and UV				renderhitData.x=vectorShape.x;				renderhitData.y=vectorShape.y;				renderhitData.z=vectorShape.z;				renderhitData.u=0;				renderhitData.v=0;				}						return renderhitData;		}	}