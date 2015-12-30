package org.papervision3d.core.effects.utils;

class ConvolutionMatrices
{
	public static var SHARPEN:Array<Dynamic>=[0, -1, 0, -1, 20, -1, 0, -1, 0];
	public static var BRIGHTNESS:Array<Dynamic>=[5, 5, 5, 5, 0, 5, 5, 5, 5];
	public static var EXTRUDE:Array<Dynamic>=[-30, 30, 0,-30, 30, 0,-30, 30, 0];
	public static var EMBOSS:Array<Dynamic>=[-2, -1, 0, -1, 1, 1, 0, 1, 2];
	public static var BLUR:Array<Dynamic>=[1, 1, 1, 1, 1, 1, 1, 1, 1];

}