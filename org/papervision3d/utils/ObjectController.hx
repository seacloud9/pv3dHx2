package org.papervision3d.utils;
 
/*
Copyright(c)2007 John Grden

Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files(the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
/**
 * @author John Grden
 */
import flash.display.Stage;
import flash.events.EventDispatcher;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;

import org.papervision3d.objects.DisplayObject3D;

//import com.blitzagency.xray.logger.XrayLog;	

//import com.rockonflash.papervision3d.modelviewer.events.ObjectControllerEvent;

class DynamicController extends EventDispatcher
{
	private static var _instance:DynamicController=null;
	public static function getInstance():DynamicController
	{
		if(_instance==null)_instance=new DynamicController();
		return _instance;
	}
	
	public var isMouseDown			:Bool;
	public var restrictInversion	:Bool=false;
	
	private var currentRotationObj:DisplayObject3D;
	
	private var arrowLeft			:Bool;
	private var arrowUp			:Bool;
	private var arrowRight		:Bool;
	private var arrowDown			:Bool;
	
	private var lastX				:Float;
	private var lastY				:Float;
	private var difX				:Float;
	private var difY				:Float;
	
	
	
	private var si				:Float;
	//private var timer				:Timer=new Timer(25,0);
	
	private var movementInc		:Float=1;
	
	//private var log					:XrayLog=new XrayLog();
	private var stage				:Stage;
	
	public function new()
	{
		// constructor
		//Mouse.addListener(this);
		//Keyboard.addListener(this);
		//timer.addEventListener(TimerEvent.TIMER, handleTimerTick);
		//timer.start();
	}
	
	public function registerControlObject(obj:DisplayObject3D):Void
	{
		currentRotationObj=obj;
	}
	
	public function registerStage(p_stage:Stage):Void
	{
		stage=p_stage;
		stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		
		updateLastRotation();
		updateDif();
	}
	
	private function updateLastRotation():Void
	{
		lastX=stage.mouseX;
		lastY=stage.mouseY;
	}
	
	private function updateDif():Void
	{
		difX=Std.parseFloat(stage.mouseX - lastX);
		difY=Std.parseFloat(stage.mouseY - lastY);
	}
	
	private function onMouseDown(e:MouseEvent):Void
	{
		updateLastRotation();
		isMouseDown=true;
	}
	
	private function onMouseMove(e:MouseEvent):Void
	{
		updateMovements();
	}
	
	/*
	private function handleTimerTick(e:TimerEvent):Void
	{
		updateMovements();
	}
	*/
	
	private function onMouseUp(e:MouseEvent):Void
	{
		isMouseDown=false;
		updateLastRotation();
	}
	
	private function onKeyDown(e:KeyboardEvent):Void 
	{
		/*
		37 // left
		38 // up
		39 // right
		40 // down
		*/
		try
		{
			movementInc +=movementInc*.1;
			//log.debug("keyDown", e.keyCode);
			switch(e.keyCode)
			{
				case 37:
					arrowLeft=true;
				break;
				
				case 38:
					arrowUp=true;
				break;
				
				case 39:
					arrowRight=true;
				break;
				
				case 40:
					arrowDown=true;
				break;
			}
			
		}catch(e:Dynamic)
		{
			trace("keyDown error");
		}
	}
	
	private function onKeyUp(e:KeyboardEvent):Void 
	{
		movementInc=1;
		try
		{
			switch(e.keyCode)
			{
				case 37:
					arrowLeft=false;
				break;
				
				case 38:
					arrowUp=false;
				break;
				
				case 39:
					arrowRight=false;
				break;
				
				case 40:
					arrowDown=false;
				break;
			}
		}catch(e:Dynamic)
		{
			trace("keyDown error");
		}
	}
		
	private function handleKeyStroke():Void
	{
		var inc:Float=5 + movementInc;
		
		if(arrowLeft)currentRotationObj.x -=inc;
		if(arrowUp)currentRotationObj.z +=inc;
		if(arrowRight)currentRotationObj.x +=inc;
		if(arrowDown)currentRotationObj.z -=inc;
	}
	
	private function updateMovements():Void
	{
		updateDif();
		handleKeyStroke();
		
		if(!isMouseDown)return;
		
		try
		{
			var posx:Float=difX/7;
			var posy:Float=difY/7;
			
			posx=posx>360 ? posx % 360:posx;
			posy=posy>360 ? posy % 360:posy;
			
			if(restrictInversion && currentRotationObj.rotationX - posy>=(-90)&& currentRotationObj.rotationX - posy<=(90))
			{
				currentRotationObj.rotationX -=posy;
			}else if(!restrictInversion)
			{
				currentRotationObj.rotationX -=posy;
			}
			currentRotationObj.rotationY +=posx;
			//dispatchEvent(new DynamicControllerEvent(ObjectControllerEvent.MOVEMENT, posx, posy));
			
			if(difX !=0)lastX=stage.mouseX;
			if(difY !=0)lastY=stage.mouseY;
		}catch(e:Dynamic)
		{
			trace("handleMouseMove failed");
		}
	}
}