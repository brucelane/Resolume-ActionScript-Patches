package resolume.display {
	
	import flash.display.*;
	
	final public class Surface extends BitmapData {
		
		/**
		 * 	@public
		 */
		public function Surface(width:int, height:int, alpha:Boolean = true):void {
			super(width, height, alpha, 0);
		}
	}
}