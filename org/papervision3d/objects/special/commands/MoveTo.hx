package org.papervision3d.objects.special.commands {	import flash.display.Graphics;			import org.papervision3d.core.geom.renderables.Vertex3D;			/**	 * @author Mark Barcinski	 */	class MoveTo implements IVectorShape{		public var vertex:Vertex3D;		public function new(vertex:Vertex3D){			this.vertex=vertex;			}		public function draw(graphics:Graphics , prevDrawn:Bool):Bool {			if(vertex.vertex3DInstance.visible){				graphics.moveTo(vertex.vertex3DInstance.x , vertex.vertex3DInstance.y);								return true;				}						return false;		}	}