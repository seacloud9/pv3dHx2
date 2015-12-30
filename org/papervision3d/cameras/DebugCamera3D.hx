package org.papervision3d.cameras;

import flash.display.Sprite;
import flash.display.Stage;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.ui.Keyboard;

import org.papervision3d.view.Viewport3D;

/**
 *<p>
 * DebugCamera3D serves as a tool to allow you control
 * the camera with your mouse and keyboard while displaying information
 * about the camera when testing your swf. Due to its nature,
 * the Keyboard and Mouse Events may Interfere with your custom Keyboard and Mouse Events.
 * This camera is in no way Intended for production use.
 *</p>
 * 
 *<p>
 * Click and drag for mouse movement. The keys
 * are setup as follows:
 *</p>
 *<pre><code>
 * w=forward
 * s=backward
 * a=left
 * d=right
 * q=rotationZ--
 * e=rotationZ++
 * r=fov++
 * f=fov--
 * t=near++
 * g=near--
 * y=far++
 * h=far--
 *</code></pre>
 * 
 * @author John Lindquist
 */
class DebugCamera3D extends Camera3D
{
	/** @private */
	private var _propertiesDisplay:Sprite;
	/** @private */
	private var _inertia:Float=3;
	/** @private */
	private var viewportStage:Stage;
	/** @private */
	private var startPoint:Point;
	/** @private */
	private var startRotationY:Float;
	/** @private */
	private var startRotationX:Float;
	/** @private */
	private var targetRotationY:Float=0;
	/** @private */
	private var targetRotationX:Float=0;
	/** @private */
	private var keyRight:Bool=false;
	/** @private */
	private var keyLeft:Bool=false;
	/** @private */
	private var keyForward:Bool=false;
	/** @private */
	private var keyBackward:Bool=false;
	/** @private */
	private var forwardFactor:Float=0;
	/** @private */
	private var sideFactor:Float=0;
	/** @private */
	private var xText:TextField;
	/** @private */
	private var yText:TextField;
	/** @private */
	private var zText:TextField;
	/** @private */
	private var rotationXText:TextField;
	/** @private */
	private var rotationYText:TextField;
	/** @private */
	private var rotationZText:TextField;
	/** @private */
	private var fovText:TextField;
	/** @private */
	private var nearText:TextField;
	/** @private */
	private var farText:TextField;
	/** @private */
	private var viewport3D:Viewport3D;
	
	/**
	 * DebugCamera3D
	 *
	 * @param viewport	Viewport to render to. @see org.papervision3d.view.Viewport3D 
	 * @param fovY		Field of view(vertical)in degrees.
	 * @param near		Distance to near plane.
	 * @param far		Distance to far plane.
	 */
	public function new(viewport3D:Viewport3D, fovY:Float=90, near:Float=10, far:Float=5000)
	{
		super(fovY, near, far, true);
		
		this.viewport3D=viewport3D;
		this.viewport=viewport3D.sizeRectangle;
		
		this.focus=(this.viewport.height / 2)/ Math.tan((fovY/2)*(Math.PI/180));
		this.zoom=this.focus / near;
		this.focus=near;
		this.far=far;
		
		displayProperties();
		checkStageReady();	
	}
	
	/**
	 * Checks if the viewport is ready for events
	 */
	private function checkStageReady():Void
	{
		if(viewport3D.containerSprite.stage==null)
		{
			viewport3D.containerSprite.addEventListener(Event.ADDED_TO_STAGE, onAddedToStageHandler);
		}
		else
		{
			setupEvents();
		}
	}

	/**
	 * Dispatched with the viewport container is added to the stage
	 */
	private function onAddedToStageHandler(event:Event):Void 
	{
		setupEvents();
	}
	
	/**
	 * Builds the Sprite that displays the camera properties
	 */
	private function displayProperties():Void 
	{
		_propertiesDisplay=new Sprite();
		_propertiesDisplay.graphics.beginFill(0x000000);
		_propertiesDisplay.graphics.drawRect(0, 0, 100, 100);
		_propertiesDisplay.graphics.endFill();
		
		_propertiesDisplay.x=0;
		_propertiesDisplay.y=0;
		
		var format:TextFormat=new TextFormat("_sans", 9);
		
		xText=new TextField();
		yText=new TextField();
		zText=new TextField();
		rotationXText=new TextField();
		rotationYText=new TextField();
		rotationZText=new TextField();
		fovText=new TextField();
		nearText=new TextField();
		farText=new TextField();
		
		var textFields:Array<Dynamic>=[xText, yText, zText, rotationXText, rotationYText, rotationZText, fovText, nearText, farText];
		var textFieldYSpacing:Int=10;
		
		for(i in 0...textFields.length)
		{
			textFields[i].width=100;
			textFields[i].selectable=false;
			textFields[i].textColor=0xFFFF00;
			textFields[i].text='';
			textFields[i].defaultTextFormat=format;
			textFields[i].y=textFieldYSpacing * i;
			_propertiesDisplay.addChild(textFields[i]);
		}
		
		
		viewport3D.addChild(_propertiesDisplay);
	}
	
	/**
	 * Sets up the Mouse and Keyboard Events required for adjusting the camera properties
	 */
	private function setupEvents():Void 
	{
		viewportStage=viewport3D.containerSprite.stage;
		viewportStage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
		viewportStage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		viewportStage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
		viewportStage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
		viewportStage.addEventListener(Event.ENTER_FRAME, onEnterFrameHandler);
	}
	
	/**
	 *  The default handler for the<code>MouseEvent.MOUSE_DOWN</code>event.
	 *
	 *  @param The event object.
	 */
	private function mouseDownHandler(event:MouseEvent):Void 
	{
		viewportStage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
		startPoint=new Point(viewportStage.mouseX, viewportStage.mouseY);
		startRotationY=this.rotationY;
		startRotationX=this.rotationX;
	}
		
	/**
	 *  The default handler for the<code>MouseEvent.MOUSE_MOVE</code>event.
	 *
	 *  @param The event object.
	 */
	private function mouseMoveHandler(event:MouseEvent):Void 
	{
		targetRotationY=startRotationY -(startPoint.x - viewportStage.mouseX)/ 2;
		targetRotationX=startRotationX +(startPoint.y - viewportStage.mouseY)/ 2;
	}
	
	/**
	 *  Removes the mouseMoveHandler on the<code>MouseEvent.MOUSE_UP</code>event.
	 *
	 *  @param The event object.
	 */
	private function mouseUpHandler(event:MouseEvent):Void 
	{
		viewportStage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
	}

	/**
	 *  Adjusts the camera based on the keyCode from the<code>KeyboardEvent.KEY_DOWN</code>event.
	 *
	 *  @param The event object.
	 */
	private function keyDownHandler(event:KeyboardEvent):Void 
	{
		switch(event.keyCode)
		{
			case "W".charCodeAt():
			case Keyboard.UP:
				keyForward=true;
				keyBackward=false;
				break;

			case "S".charCodeAt():
			case Keyboard.DOWN:
				keyBackward=true;
				keyForward=false;
				break;

			case "A".charCodeAt():
			case Keyboard.LEFT:
				keyLeft=true;
				keyRight=false;
				break;

			case "D".charCodeAt():
			case Keyboard.RIGHT:
				keyRight=true;
				keyLeft=false;
				break;
				
			case "Q".charCodeAt():
				rotationZ--;
				break;
			
			case "E".charCodeAt():
				rotationZ++;
				break;
			
			case "F".charCodeAt():
				fov--;
				break;
				
			case "R".charCodeAt():
				fov++;
				break;
				
			case "G".charCodeAt():
				near -=10;
				break;
				
			case "T".charCodeAt():
				near +=10;
				break;
				
			case "H".charCodeAt():
				far -=10;
				break;
				
			case "Y".charCodeAt():
				far +=10;
				break;
		}
	}
	
	/**
	 *  Checks which Key is released on the<code>KeyboardEvent.KEY_UP</code>event
	 *  and toggles that key's movement off.
	 *
	 *  @param The event object.
	 */
	private function keyUpHandler(event:KeyboardEvent):Void 
	{
		switch(event.keyCode)
		{
			case "W".charCodeAt():
			case Keyboard.UP:
				keyForward=false;
				break;

			case "S".charCodeAt():
			case Keyboard.DOWN:
				keyBackward=false;
				break;

			case "A".charCodeAt():
			case Keyboard.LEFT:
				keyLeft=false;
				break;

			case "D".charCodeAt():
			case Keyboard.RIGHT:
				keyRight=false;
				break;
		}
	}

	/**
	 *  Checks which keys are down and adjusts the camera accorindingly on the<code>Event.ENTER_FRAME</code>event.
	 *  Also updates the display of properties.
	 *
	 *  @param The event object.
	 */
	private function onEnterFrameHandler(event:Event):Void 
	{
		if(keyForward)
		{
			forwardFactor +=50;
		}
		if(keyBackward)
		{
			forwardFactor +=-50;
		}
		if(keyLeft)
		{
			sideFactor +=-50;
		}
		if(keyRight)
		{
			sideFactor +=50;
		}
		
		// rotation
		var rotationX:Float=this.rotationX +(targetRotationX - this.rotationX)/ _inertia;
		var rotationY:Float=this.rotationY +(targetRotationY - this.rotationY)/ _inertia;
		this.rotationX=Math.round(rotationX * 10)/ 10;
		this.rotationY=Math.round(rotationY * 10)/ 10;
		
		// position
		forwardFactor +=(0 - forwardFactor)/ _inertia;
		sideFactor +=(0 - sideFactor)/ _inertia;
		if(forwardFactor>0)
		{
			this.moveForward(forwardFactor);
		}else 
		{
			this.moveBackward(-forwardFactor);
		}
		if(sideFactor>0)
		{
			this.moveRight(sideFactor);
		}else 
		{
			this.moveLeft(-sideFactor);
		}
		
		xText.text='x:' + Std.int(x);
		yText.text='y:' + Std.int(y);
		zText.text='z:' + Std.int(z);
		
		rotationXText.text='rotationX:' + Std.int(rotationX);
		rotationYText.text='rotationY:' + Std.int(rotationY);
		rotationZText.text='rotationZ:' + Std.int(rotationZ);
		
		fovText.text='fov:' + Math.round(fov);
		nearText.text='near:' + Math.round(near);
		farText.text='far:' + Math.round(far);
	}

	/**
	 * A Sprite that displays the current properties of your camera
	 */	
	public var propsDisplay(get_propsDisplay, set_propsDisplay):Sprite;
 	private function get_propsDisplay():Sprite 
	{
		return _propertiesDisplay;
	}

	private function set_propsDisplay(propsDisplay:Sprite):Void 
	{
		_propertiesDisplay=propsDisplay;
	}

	/**
	 * The amount of resistance to the change in velocity when updating the camera rotation with the mouse
	 */
	public var inertia(get_inertia, set_inertia):Float;
 	private function get_inertia():Float 
	{
		return _inertia;
	}

	private function set_inertia(inertia:Float):Void 
	{
		_inertia=inertia;
	}
}