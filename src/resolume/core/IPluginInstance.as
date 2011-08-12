package resolume.core {
	
	import flash.events.*;
	import flash.geom.*;
	
	import resolume.display.*;
	import resolume.parameter.*;
	
	/**
	 * 
	 */
	public interface IPluginInstance extends IDisposable, ISerializable, IParameterObject {
		
		/**
		 * 	@public
		 */
		function get id():String;
		
		/**
		 * 	@public
		 */
		function get name():String;
		
	}
}