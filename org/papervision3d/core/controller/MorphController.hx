package org.papervision3d.core.controller;
	import org.papervision3d.core.geom.TriangleMesh3D;	import org.papervision3d.core.geom.renderables.Vertex3D;	import org.papervision3d.core.log.PaperLogger;		/**	 * The MorphController class controls a mesh's vertices by applying a morph.	 * 	 * Each possible mesh that can be blended(a morph target)must be specified.	 * Each morph target is assigned a blend weight. The result is obtained via two methods:	 * 	 *<ol>	 *<li>NORMALIZED(Target1, Target2, ...)*(w1, w2, ...)=(1-w1-w2-...)*BaseMesh + w1*Target1 + w2*Target2 + ...</li>	 *<li>RELATIVE	(Target1, Target2, ...)+(w1, w2, ...)=BaseMesh + w1*Target1 + w2*Target2 + ...</li>	 *</ol>	 * 	 * @author Tim Knip / floorplanner.com	 */	class MorphController implements IObjectController	{		/** */		public var active:Bool;				/** */		public var target:TriangleMesh3D;				/** */		public var targets:Array<Dynamic>;				/** */		public var weights:Array<Dynamic>;				/** */		public var normalized:Bool;				/** */		private var cached:Array<Dynamic>;				/**		 * Constructor.		 */ 		public function new(target:TriangleMesh3D, normalized:Bool=true)		{			this.target=target;			this.active=true;			this.targets=new Array();			this.normalized=normalized;			this.weights=new Array();			this.cached=new Array(target.geometry.vertices.length);						var v:Vertex3D;			for(i in 0...cached.length)			{				v=target.geometry.vertices[i];				cached[i]=v.clone();			}		}		/**		 * 		 */		public function addMorphTarget(mesh:TriangleMesh3D, weight:Float):Void		{			if(mesh.geometry.vertices.length !=this.target.geometry.vertices.length)			{				PaperLogger.warning("Invalid morph target! " +					"Number of specified vertices(" + mesh.geometry.vertices.length + ")" +					" not equal to number of base vertices(" +					+this.target.geometry.vertices.length + ").");				return;			}						this.targets.push(mesh);			this.weights.push(weight);		}				/**		 * 		 */ 		public function update():Void		{			var orig:Array<Dynamic>=this.target.geometry.vertices;			var cached:Array<Dynamic>=this.cached;			var mesh:TriangleMesh3D;			var c:Vertex3D, v:Vertex3D, t:Vertex3D;			var num:Int=orig.length;			var totalWeight:Float=0;			var restWeight:Float, weight:Float;			var i:Int, j:Int;						if(!this.active)			{				return;			}						if(normalized)			{				for(i=0;i<weights.length;i++)				{					totalWeight +=weights[i];				}				restWeight=1 - totalWeight;			}						for(i=0;i<num;i++)			{				v=orig[i];				c=cached[i];								v.x=normalized ? restWeight * c.x:c.x;				v.y=normalized ? restWeight * c.y:c.y;				v.z=normalized ? restWeight * c.z:c.z;								for(j=0;j<targets.length;j++)				{					mesh=targets[j];					t=mesh.geometry.vertices[i];					weight=weights[j];										v.x +=weight * t.x;					v.y +=weight * t.y;					v.z +=weight * t.z;				}			}		}	}