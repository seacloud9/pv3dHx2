package org.papervision3d.core.render.sort;


class NullSorter implements IRenderSorter
{
	
	/**
	 * NullSorter();
	 * 
	 * Doesn't do anything to the renderlist, during the sort phase.
	 */
	public function new()
	{
	}
	
	public function sort(array:Array):Void
	{
		//Do absolutely nothing
	}
	
}