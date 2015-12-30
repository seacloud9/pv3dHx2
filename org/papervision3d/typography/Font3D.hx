package org.papervision3d.typography {	/**	 * @author Mark Barcinski	 */	class Font3D {		public var motifs(get_motifs, null):Dynamic;
 	private function get_motifs():Dynamic		{			//Override me			return new Dynamic();		}				public var widths(get_widths, null):Dynamic;
 	private function get_widths():Dynamic		{			//Override me			return new Dynamic();		}				public var height(get_height, null):Float;
 	private function get_height():Float		{ 			//Override me			return -1;		}			}