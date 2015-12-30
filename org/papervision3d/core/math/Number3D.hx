﻿package org.papervision3d.core.math;
	import org.papervision3d.Papervision3D;	/*** The Float3D class represents a value in a three-dimensional coordinate system.** Properties x, y and z represent the horizontal, vertical and z the depth axes respectively.**/class Float3D{	/**	* The horizontal coordinate value.	*/	public var x:Float;	/**	* The vertical coordinate value.	*/	public var y:Float;	/**	* The depth coordinate value.	*/	public var z:Float;	/**	 * pre-made Float3D:used by various methods as a way to temporarily store Float3Ds. 	 */	static private var temp:Float3D=Number3D.ZERO;		static public var toDEGREES:Float=180/Math.PI;	static public var toRADIANS:Float=Math.PI/180;		/**	* Creates a new Float3D object whose three-dimensional values are specified by the x, y and z parameters. If you call this constructor function without parameters, a Float3D with x, y and z properties set to zero is created.	*	* @param	x	The horizontal coordinate value. The default value is zero.	* @param	y	The vertical coordinate value. The default value is zero.	* @param	z	The depth coordinate value. The default value is zero.	*/	public function new(x:Float=0, y:Float=0, z:Float=0)	{		this.x=x;		this.y=y;		this.z=z;	}	/**	* Returns a new Float3D object that is a clone of the original instance with the same three-dimensional values.	*	* @return	A new Float3D instance with the same three-dimensional values as the original Float3D instance.	*/	public function clone():Float3D	{		return new Float3D(this.x, this.y, this.z);	}		/**	 * Copies the values of this Float3d to the passed Float3d.	 * 	 */	public function copyTo(n:Float3D):Void	{		n.x=x;		n.y=y;		n.z=z;	}		/**	 * Copies the values of this Float3d to the passed Float3d.	 * 	 */	public function copyFrom(n:Float3D):Void	{		x=n.x;		y=n.y;		z=n.z;	}		/** 	 * Quick way to set the properties of the Float3D	 * 	 */	public function reset(newx:Float=0, newy:Float=0, newz:Float=0):Void	{		x=newx;		y=newy;		z=newz;	}	// ______________________________________________________________________ MATH	/**	* Modulo	*/	public var modulo(get_modulo, null):Float;
 	private function get_modulo():Float	{		return Math.sqrt(this.x*this.x + this.y*this.y + this.z*this.z);	}	/**	* Add	*/	public static function add(v:Float3D, w:Float3D):Float3D	{		return new Float3D		(			v.x + w.x,			v.y + w.y,			v.z + w.z		);	}	/**	 * Subtract.	 */	public static function sub(v:Float3D, w:Float3D):Float3D	{		return new Float3D		(			v.x - w.x,			v.y - w.y,			v.z - w.z		);	}	/**	 * Dot product.	 */	public static function dot(v:Float3D, w:Float3D):Float	{		return(v.x * w.x + v.y * w.y + w.z * v.z);	}	/**	 * Cross product. Now optionally takes a target Float3D to put the change Into. So we're not constantly making new number3Ds. 	 * Maybe make a crossEq function? 	 */	public static function cross(v:Float3D, w:Float3D, targetN:Float3D=null):Float3D	{		if(!targetN)targetN=ZERO;		 		targetN.reset((w.y * v.z)-(w.z * v.y),(w.z * v.x)-(w.x * v.z),(w.x * v.y)-(w.y * v.x));		return targetN;	}	/**	 * Normalize.	 */	public function normalize():Void	{		var mod:Float=Math.sqrt(this.x*this.x + this.y*this.y + this.z*this.z);		if(mod !=0 && mod !=1)		{			mod=1 / mod;// mults are cheaper then divs			this.x *=mod;			this.y *=mod;			this.z *=mod;		}	}	/**	 * Multiplies the vector by a number. The same as the *=operator	 */	public function multiplyEq(n:Float):Void	{		x*=n;		y*=n;		z*=n;		}		/**	 * Adds the vector passed to this vector. The same as the +=operator. 	 */	public function plusEq(v:Float3D):Void	{		x+=v.x;		y+=v.y;		z+=v.z;		}		/**	 * Subtracts the vector passed to this vector. The same as the -=operator. 	 */		public function minusEq(v:Float3D):Void	{		x -=v.x;		y -=v.y;		z -=v.z;				}	// ______________________________________________________________________		/**	 * Super fast modulo(length, magnitude)comparisons.	 * 	 *  	 */	public function isModuloLessThan(v:Float):Bool	{					return(moduloSquared<(v*v));			}		public function isModuloGreaterThan(v:Float):Bool	{					return(moduloSquared>(v*v));			}	public function isModuloEqualTo(v:Float):Bool	{					return(moduloSquared==(v*v));			}			public var modulo(get_modulo, null):Float;
 	private function get_moduloSquared():Float	{		return(this.x*this.x + this.y*this.y + this.z*this.z);	}			// ______________________________________________________________________	/**	* Returns a Float3D object with x, y and z properties set to zero.	*	* @return A Float3D object.	*/	static public var ZERO(get_ZERO, null):Float3D;
 	private function get_ZERO():Float3D	{		return new Float3D(0, 0, 0);	}	/**	* Returns a string value representing the three-dimensional values in the specified Float3D object.	*	* @return	A string.	*/	public function toString():String	{		return 'x:' + Math.round(x*100)/100 + ' y:' + Math.round(y*100)/100 + ' z:' + Math.round(z*100)/100;				}		//------- TRIG FUNCTIONS		/**	 * 	 * 	 * 	 */		public function rotateX(angle:Float):Void	{		if(Papervision3D.useDEGREES)angle*=toRADIANS;				var cosRY:Float=Math.cos(angle);		var sinRY:Float=Math.sin(angle);		temp.copyFrom(this);		this.y=(temp.y*cosRY)-(temp.z*sinRY);		this.z=(temp.y*sinRY)+(temp.z*cosRY);			}		public function rotateY(angle:Float):Void	{				if(Papervision3D.useDEGREES)angle*=toRADIANS;				var cosRY:Float=Math.cos(angle);		var sinRY:Float=Math.sin(angle);		temp.copyFrom(this);				this.x=(temp.x*cosRY)+(temp.z*sinRY);		this.z=(temp.x*-sinRY)+(temp.z*cosRY);					}		public function rotateZ(angle:Float):Void	{				if(Papervision3D.useDEGREES)angle*=toRADIANS;		var cosRY:Float=Math.cos(angle);		var sinRY:Float=Math.sin(angle);		temp.copyFrom(this);				//this.x=temp.x;		this.x=(temp.x*cosRY)-(temp.y*sinRY);		this.y=(temp.x*sinRY)+(temp.y*cosRY);					}}