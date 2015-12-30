/*
 * Copyright 2007(c)Tim Knip, ascollada.org.
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files(the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */
 
package org.ascollada.core;

import org.ascollada.core.DaeEntity;

/**
 * 
 */
class DaeAnimationCurve extends DaeEntity
{
	public static inline var INTERPOLATION_STEP:Int=0;//equivalent to no Interpolation
	public static inline var INTERPOLATION_LINEAR:Int=1;
	public static inline var INTERPOLATION_BEZIER:Int=2;
	public static inline var INTERPOLATION_TCB:Int=3;
	public static inline var INTERPOLATION_UNKNOWN:Int=4;
	public static inline var INTERPOLATION_DEFAULT:Int=0;
	
	public static inline var INFINITY_CONSTANT:Int=0;
	public static inline var INFINITY_LINEAR:Int=1;
	public static inline var INFINITY_CYCLE:Int=2;
	public static inline var INFINITY_CYCLE_RELATIVE:Int=3;
	public static inline var INFINITY_OSCILLATE:Int=4;
	public static inline var INFINITY_UNKNOWN:Int=5;
	public static inline var INFINITY_DEFAULT:Int=0;
	
	public var keys:Array<Dynamic>;
	public var keyValues:Array<Dynamic>;
	
	public var Interpolations:Array<Dynamic>;
	
	public var inTangents:Array<Dynamic>;
	
	public var outTangents:Array<Dynamic>;
	
	public var tcbParameters:Array<Dynamic>;
	
	public var easeInOuts:Array<Dynamic>;
	
	public var preInfinity:Int=0;
	
	public var postInfinity:Int=0;
	
	public var InterpolationType:Int=1;
	
	/**
	 * 
	 * @param	keys
	 * @param	keyValues
	 */
	public function new(keys:Array<Dynamic>=null, keyValues:Array<Dynamic>=null):Void
	{			
		super(null, null);
		this.keys=keys || new Array();
		this.keyValues=keyValues || new Array();
		this.interpolations=new Array();
	}
	
	/**
	 * main workhorse for the animation system.
	 * 
	 * @param	time
	 * 
	 * @return
	 */
	public function evaluate(dt:Float):Float
	{
		// Check for empty curves and poses(curves with 1 key).
		if(!this.keys.length)return 0.0;
		if(this.keys.length==1)return this.keyValues[0];
		
		var i:Int;
		var outputStart:Float=this.keyValues[0];
		var outputEnd:Float=this.keyValues[this.keyValues.length-1];
		var inputStart:Float=this.keys[0];
		var inputEnd:Float=this.keys[this.keys.length-1];
		var inputSpan:Float=inputEnd - inputStart;
		var cycleCount:Float;
		
		dt=dt % inputEnd;
					
		// Account for pre-infinity mode
		var outputOffset:Float=0.0;
		
		if(dt<=inputStart)
		{
			switch(preInfinity)
			{
				case INFINITY_CONSTANT:return outputStart;
				case INFINITY_LINEAR:return outputStart +(dt - inputStart)*(keyValues[1] - outputStart)/(keys[1] - inputStart);
				case INFINITY_CYCLE:{ cycleCount=Math.ceil((inputStart - dt)/ inputSpan);dt +=cycleCount * inputSpan;break;}
				case INFINITY_CYCLE_RELATIVE:{ cycleCount=Math.ceil((inputStart - dt)/ inputSpan);dt +=cycleCount * inputSpan;outputOffset -=cycleCount *(outputEnd - outputStart);break;}
				case INFINITY_OSCILLATE:{ cycleCount=Math.ceil((inputStart - dt)/(2.0 * inputSpan));dt +=cycleCount * 2.0 * inputSpan;dt=inputEnd - Math.abs(dt - inputEnd);break;}
				case INFINITY_UNKNOWN:default:return outputStart;
			}
		}
		else if(dt>=inputEnd)
		{
			// Account for post-infinity mode
			switch(postInfinity)
			{
				case INFINITY_CONSTANT:return outputEnd;
				case INFINITY_LINEAR:return outputEnd +(dt - inputEnd)*(keyValues[keys.length - 2] - outputEnd)/(keys[keys.length - 2] - inputEnd);
				case INFINITY_CYCLE:{ cycleCount=Math.ceil((dt - inputEnd)/ inputSpan);dt -=cycleCount * inputSpan;break;}
				case INFINITY_CYCLE_RELATIVE:{ cycleCount=Math.ceil((dt - inputEnd)/ inputSpan);dt -=cycleCount * inputSpan;outputOffset +=cycleCount *(outputEnd - outputStart);break;}
				case INFINITY_OSCILLATE:
					cycleCount=Math.ceil((dt - inputEnd)/(2.0 * inputSpan));
					dt -=cycleCount * 2.0 * inputSpan;
					dt=inputStart + Math.abs(dt - inputStart);
					break;
				case INFINITY_UNKNOWN:default:
					return outputEnd;
			}
		}
		
		// speed up Interval search
		var approxi:Int=Math.ceil((dt/inputEnd)* this.keys.length);
		
		// Find the current Interval
		for(i=approxi;i<this.keys.length;++i)
			if(this.keys[i]>dt)break;
		var index:Int=i;
		
		// Get the keys and values for this Interval
		var endKey:Float=this.keys[index];
		var startKey:Float=this.keys[index - 1];
		var endValue:Float=this.keyValues[index];
		var startValue:Float=this.keyValues[index - 1];
		var output:Float;
		
		switch(interpolationType)
		{
			case INTERPOLATION_LINEAR:
				output=(dt - startKey)/(endKey - startKey)*(endValue - startValue)+ startValue;
				break;
				
			case INTERPOLATION_STEP:
			default:
				output=startValue;
				break;
		}

		return outputOffset + output;
	}
}