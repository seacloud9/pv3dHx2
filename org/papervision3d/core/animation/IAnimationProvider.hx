package org.papervision3d.core.animation 
{
import org.papervision3d.core.controller.AnimationController;			/**	 * @author Tim Knip / floorplanner.com	 */	interface IAnimationProvider 	{		/**		 * Gets /sets the animation controller.
	 * 
	 * @see org.papervision3d.core.controller.AnimationController		 */
	function set animation(value:AnimationController):Void;
	function get animation():AnimationController;	}