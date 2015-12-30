﻿package org.papervision3d.core.utils;



import flash.display.Sprite;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.MouseEvent;
import flash.geom.Point;

import org.papervision3d.core.geom.renderables.Triangle3D;
import org.papervision3d.core.proto.MaterialObject3D;
import org.papervision3d.core.render.data.RenderHitData;
import org.papervision3d.core.utils.virtualmouse.IVirtualMouseEvent;
import org.papervision3d.core.utils.virtualmouse.VirtualMouse;
import org.papervision3d.events.InteractiveScene3DEvent;
import org.papervision3d.materials.MovieMaterial;
import org.papervision3d.objects.DisplayObject3D;
import org.papervision3d.view.Viewport3D;

/**
* @author John Grden
*/
class InteractiveSceneManager extends EventDispatcher
{
	/**
	* MOUSE_IS_DOWN is a quick static property to check and is maintained by the ISM
	*/
	public static var MOUSE_IS_DOWN:Bool=false;
	
	/**
	* VirtualMouse is used with faceLevelMode of ISM or DO3D's.  Its a virtual mouse that causes the objects in your materials movieclip containers to fire off their mouse events such as click, over, out, release, press etc
	 *</p>
	 *<p>
	 * Using these events requires you only to do what you normally do - establish listeners with your objects like you normally would, and you'll receive them!
	*/		
	public var virtualMouse:VirtualMouse=new VirtualMouse();
	public var mouse3D:Mouse3D=new Mouse3D();
	public var viewport:Viewport3D;
	
	/**
	* Main container for ISM to create the sub InteractiveSprite containers for the faces and DO3D objects passed in during the render loop
	*/		
	public var container:Sprite;
	
	public var renderHitData:RenderHitData;	
	public var currentDisplayObject3D:DisplayObject3D;
	public var currentMaterial:MaterialObject3D;
	public var enableOverOut:Bool=true;
	public var currentMouseDO3D:DisplayObject3D=null;
	public var debug:Bool=false;
	
	public var currentMousePos:Point=new Point();
	public var lastMousePos:Point=new Point();
	
	public var _viewportRendered:Bool=false;
	
	
	
	public function new(viewport:Viewport3D)
	{
		this.viewport=viewport;
		this.container=viewport.containerSprite;
		init();
	}
	
	public function destroy():Void
	{
		viewport=null;
		renderHitData=null;
		currentDisplayObject3D=null;
		currentMaterial=null;
		currentMouseDO3D=null;
		
		virtualMouse.stage=null;
		virtualMouse.container=null;
		
		container.removeEventListener(MouseEvent.MOUSE_DOWN, handleMousePress);
		container.removeEventListener(MouseEvent.MOUSE_UP, handleMouseRelease);
		container.removeEventListener(MouseEvent.CLICK, handleMouseClick);
		container.removeEventListener(MouseEvent.DOUBLE_CLICK, handleMouseDoubleClick);
		if(container.stage)
			container.stage.removeEventListener(Event.ENTER_FRAME, handleEnterFrame);
		container=null;
	}
	
	public function init():Void
	{		
		if(container)
		{
			if(container.stage)
			{	
				initVirtualMouse();
				initListeners();
			}else
			{
				container.addEventListener(Event.ADDED_TO_STAGE, handleAddedToStage, false, 0, true);
			}				
		}
	}
	
	/**
	 * @private
	 * @param e
	 * 
	 */		
	private function handleAddedToStage(e:Event):Void
	{			
		container.removeEventListener(Event.ADDED_TO_STAGE, handleAddedToStage);

		initVirtualMouse();			
		initListeners();
	}
	
	private function initVirtualMouse():Void
	{
		// set the virtualMouse stage
		virtualMouse.stage=container.stage;
		virtualMouse.container=container;// might set this to stage later
	}
	
	public function initListeners():Void
	{
		if(viewport.interactive)
		{
			// setup listeners
			container.addEventListener(MouseEvent.MOUSE_DOWN, handleMousePress, false, 0, true);
			container.addEventListener(MouseEvent.MOUSE_UP, handleMouseRelease, false, 0, true);
			container.addEventListener(MouseEvent.CLICK, handleMouseClick, false, 0, true);
			container.addEventListener(MouseEvent.DOUBLE_CLICK, handleMouseDoubleClick, false, 0, true);
			container.stage.addEventListener(Event.ENTER_FRAME, handleEnterFrame, false, 0, true);
			
		}
	}
	
	public function updateRenderHitData():Void
	{
		resolveRenderHitData();
		
		currentDisplayObject3D=renderHitData.displayObject3D;
		currentMaterial=renderHitData.material;
		
		// when we move the mouse, we assess if there is need to dispatch Over/Out calls
		manageOverOut();
	}
	
	private function manageOverOut():Void
	{
		if(!enableOverOut)return;
		
		if(renderHitData && renderHitData.hasHit)
		{
			if(!currentMouseDO3D && currentDisplayObject3D)
			{
				handleMouseOver(currentDisplayObject3D);
				currentMouseDO3D=currentDisplayObject3D;
			}
			else if(currentMouseDO3D && currentMouseDO3D !=currentDisplayObject3D)
			{
				handleMouseOut(currentMouseDO3D);
				handleMouseOver(currentDisplayObject3D);
				currentMouseDO3D=currentDisplayObject3D;
			}
		}
		else
		{
			if(currentMouseDO3D !=null)
			{
				handleMouseOut(currentMouseDO3D);
				currentMouseDO3D=null;
			}
		}
	}
	
	private function resolveRenderHitData():Void
	{
		renderHitData=viewport.hitTestPoint2D(currentMousePos)as RenderHitData;
	}
	
	/**
	 * Handles the MOUSE_DOWN event on an InteractiveSprite container
	 * @param e
	 * 
	 */		
	private function handleMousePress(e:MouseEvent):Void
	{
		if(Std.is(e, IVirtualMouseEvent))return;
		MOUSE_IS_DOWN=true;
		if(virtualMouse)virtualMouse.press();
		if(Mouse3D.enabled && renderHitData && renderHitData.renderable !=null)mouse3D.updatePosition(renderHitData);
		if(renderHitData && renderHitData.hasHit){
			dispatchObjectEvent(InteractiveScene3DEvent.OBJECT_PRESS, currentDisplayObject3D);
		}
	}
	/**
	 * Handles the MOUSE_UP event on an InteractiveSprite container
	 * @param e
	 * 
	 */		
	private function handleMouseRelease(e:MouseEvent):Void
	{
		if(Std.is(e, IVirtualMouseEvent))return;
		MOUSE_IS_DOWN=false;
		if(virtualMouse)virtualMouse.release();
		if(Mouse3D.enabled && renderHitData && renderHitData.renderable !=null)mouse3D.updatePosition(renderHitData);
		if(renderHitData && renderHitData.hasHit)dispatchObjectEvent(InteractiveScene3DEvent.OBJECT_RELEASE, currentDisplayObject3D);
	}
	/**
	 * Handles the MOUSE_CLICK event on an InteractiveSprite container
	 * @param e
	 * 
	 */		
	private function handleMouseClick(e:MouseEvent):Void
	{
		if(Std.is(e, IVirtualMouseEvent))return;
		if(renderHitData && renderHitData.hasHit)dispatchObjectEvent(InteractiveScene3DEvent.OBJECT_CLICK, currentDisplayObject3D);
	}
	/**
	 * Handles the MOUSE_CLICK event on an InteractiveSprite container
	 * @param e
	 * 
	 */		
	private function handleMouseDoubleClick(e:MouseEvent):Void
	{
		if(Std.is(e, IVirtualMouseEvent))return;
		if(renderHitData && renderHitData.hasHit)dispatchObjectEvent(InteractiveScene3DEvent.OBJECT_DOUBLE_CLICK, currentDisplayObject3D);
	}
	/**
	 * Handles the MOUSE_OVER event on an InteractiveSprite container
	 * @param e
	 * 
	 */		
	
	private function handleMouseOver(DO3D:DisplayObject3D):Void
	{
		if(hasMouseMoved())dispatchObjectEvent(InteractiveScene3DEvent.OBJECT_OVER, DO3D);
	}
	
	/**
	 * Handles the MOUSE_OUT event on an InteractiveSprite container
	 * @param e
	 * 
	 */		
	private function handleMouseOut(DO3D:DisplayObject3D):Void
	{
		if(!hasMouseMoved())return;
		
		if(DO3D)
		{
			var mat:MovieMaterial=DO3D.material as MovieMaterial;
			if(mat)virtualMouse.exitContainer();
		}
		
		dispatchObjectEvent(InteractiveScene3DEvent.OBJECT_OUT, DO3D);	
	}
	
	public function updateAfterRender():Void
	{
		_viewportRendered=true;
	}
	
	private function hasMouseMoved():Bool
	{
		currentMousePos.x=container.mouseX;
		currentMousePos.y=container.mouseY;
	
		return !currentMousePos.equals(lastMousePos);
	}
	
	/**
	 * This handles the MOUSE_MOVE event on an InteractiveSprite container
	 * and replaces handleMouseMove. 
	 * 
	 * By using ENTER_FRAME and manually checking for mouse movement we should save CPU.
	 * 
	 * @param e
	 * 
	 */		
	private function handleEnterFrame(e:Event):Void
	{		
		var mousemoved:Bool=hasMouseMoved();
		
		if(mousemoved || _viewportRendered)
		{
			
			updateRenderHitData();
			_viewportRendered=false;
			
			if(Std.is(e, IVirtualMouseEvent))return;
			if(virtualMouse && renderHitData)
			{
				// locate the material's movie
				var mat:MovieMaterial=cast(currentMaterial, MovieMaterial);
				
				if(mat)
				{
					//log.debug("found moviematerial, setting as container", container.name, mat.name);
					// set the location where the calcs should be performed
					virtualMouse.container=mat.movie as Sprite;
				}
				
				// update virtual mouse so it can test
				if(virtualMouse.container)virtualMouse.setLocation(renderHitData.u, renderHitData.v);
				
				// update the position mouse3D
				if(Mouse3D.enabled && renderHitData && renderHitData.hasHit)mouse3D.updatePosition(renderHitData);
				
				dispatchObjectEvent(InteractiveScene3DEvent.OBJECT_MOVE, currentDisplayObject3D);
			}
			else if(renderHitData && renderHitData.hasHit)
			{
				dispatchObjectEvent(InteractiveScene3DEvent.OBJECT_MOVE, currentDisplayObject3D);
			}
			
		}
		
		lastMousePos.x=currentMousePos.x;
		lastMousePos.y=currentMousePos.y;
		
	}
	
	/**
	 * @private
	 * @param event
	 * @param currentTarget
	 * 
	 */		
	private function dispatchObjectEvent(event:String, DO3D:DisplayObject3D):Void
	{
		
		if(renderHitData && renderHitData.hasHit)
		{
			var x:Float=renderHitData.u ? renderHitData.u:0;
			var y:Float=renderHitData.v ? renderHitData.v:0;
			
			var ev:InteractiveScene3DEvent=new InteractiveScene3DEvent(event, DO3D, container, renderHitData.renderable as Triangle3D, x, y,renderHitData);
			ev.renderHitData=renderHitData;
			dispatchEvent(ev);
			DO3D.dispatchEvent(ev);
		} else 
		{
			dispatchEvent(new InteractiveScene3DEvent(event, DO3D, container));
			if(DO3D)DO3D.dispatchEvent(new InteractiveScene3DEvent(event, DO3D, container));
		}
	}
}