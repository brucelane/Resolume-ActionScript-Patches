package resolume.event {
	
	import flash.events.*;
	
	import resolume.parameter.*;
	
	final public class ParameterEvent extends Event {
		
		/**
		 * 	@public
		 */
		public static const CHANGE:String	= 'Parameter.Change';
		
		/**
		 * 	@public
		 */
		public var old:*;
		
		/**
		 * 	@public
		 */
		public var parameter:Parameter;
		
		/**
		 * 	@public
		 */
		public function ParameterEvent():void {
			super(CHANGE, false, false);
		}
		
		/**
		 * 	@public
		 */
		override public function clone():Event {
			const cloned:ParameterEvent	= new ParameterEvent();
			cloned.old					= old;
			cloned.parameter			= parameter;
			return cloned;
		}
		
		/**
		 * 	@public
		 */
		final public function dispatch(parameter:Parameter, old:*):Event {
			
			this.parameter	= parameter;
			this.old		= old;
			
			// return
			return this;
		}
		
		/**
		 * 
		 */
		CONFIG::DEBUG override public function toString():String {
			return '[ParameterEvent: ' + parameter + ', old=' + old + ']'
		}
	}
}