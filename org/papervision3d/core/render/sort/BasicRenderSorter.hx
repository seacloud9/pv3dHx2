package org.papervision3d.core.render.sort;


/**
 * @author Ralph Hauwert
 */
class BasicRenderSorter implements IRenderSorter
{
	
	//Sorts the renderlist by screenDepth.
	public function sort(array:Array):Void
	{
		array.sortOn("screenZ", Array.NUMERIC);
	}
	
}