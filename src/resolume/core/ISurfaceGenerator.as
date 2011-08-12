package resolume.core {
	
	import flash.display.*;
	import flash.geom.*;
	
	import resolume.display.*;
	import resolume.parameter.*;
	
	public interface ISurfaceGenerator extends IPluginInstance {
		
		/**
		 * 	@public
		 */
		function setup(file:IFileReference, content:Object):void;
		
		/**
		 * 	@public
		 */
		function getFile():IFileReference;
		
		/**
		 * 	@public
		 */
		function initialize(layer:IDisplayLayer, context:SurfaceContext):int;
		
		/**
		 * 	@public
		 */
		function invalidate():void;
		
		/**
		 * 	Public
		 */
		function render(context:SurfaceContext, surface:Surface):void;
		
		/**
		 * 	@public
		 * 	Time passed in is value of 0 to 1.
		 */
		function update(time:Number):void;
		
		/**
		 * 	@public
		 * 	Returns the total time in milliseconds
		 */
		function getTotalTime():int;
		
		/**
		 * 	@public
		 */
		function hasNewFrame():Boolean;
		
	}
}