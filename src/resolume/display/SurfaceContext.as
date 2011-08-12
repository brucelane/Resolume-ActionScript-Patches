package resolume.display {
	
	import flash.desktop.*;
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.ui.*;
	
	import resolume.core.*;
	import resolume.display.*;
	import resolume.util.*;
	
	final public class SurfaceContext extends DisplayContext {
		
		/**
		 * 	@public
		 */
		public static function Create(stage:Stage, width:int, height:int, frameRate:int):SurfaceContext {
			
			Initializer = {
				width:		width,
				height:		height,
				stage:		stage,
				frameRate:	frameRate
			};
			
			// return
			return new SurfaceContext();
		}
		
		/**
		 * 	@private
		 */
		private static function handleMouse(event:Event):void {
			Mouse.hide();
		}
		
		/**
		 * 	@public
		 * 	Temporary buffer in case an extra bitmap is needed
		 */
		public const buffer:Surface		= new Surface(Initializer.width, Initializer.height, true);
		
		/**
		 * 	@public
		 * 	Stores the top left 0,0
		 */
		public const identity:Point		= new Point();
		
		/**
		 * 	@public
		 */
		public const rect:Rectangle						= new Rectangle(0, 0, Initializer.width, Initializer.height);
		
		/**
		 * 	@public
		 * 	Creates a matrix from the specified width and height
		 */
		public function createMatrix(w:int, h:int, maintainAspectRatio:Boolean = true):Matrix {
			
			const matrix:Matrix	= new Matrix();
			setMatrix(matrix, w, h, maintainAspectRatio);
			
			return matrix;
		}
		
		/**
		 * 	@public
		 * 	Creates a new surface
		 */
		public function createSurface(alpha:Boolean = true):Surface {
			return new Surface(width, height, alpha);
		}
		
		/**
		 * 	@public
		 * 	Sets a matrix from a specified width/height 
		 */
		public function setMatrix(matrix:Matrix, w:int, h:int, maintainAspect:Boolean = true):void {
			
			// TODO, we need to offset to the center
			if (maintainAspect) {
				matrix.a	= matrix.d = Math.max(width / w, height / h);
			} else {
				matrix.a 	= width / w;
				matrix.d 	= height / h;
			}
		}
	}
}