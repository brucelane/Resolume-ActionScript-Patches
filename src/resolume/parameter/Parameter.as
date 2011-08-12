package resolume.parameter {
	
	import flash.events.*;
	import flash.utils.*;
	
	import resolume.core.*;
	import resolume.event.*;
	import resolume.plugin.*;
	import resolume.util.GC;
	
	use namespace parameter;
	use namespace batchass_ns;
	
	[Event(name='change', type='flash.events.Event')]
	
	public class Parameter implements IParameter {
		
		/**
		 * 	@protected
		 */
		internal static const CHANGE:ParameterEvent	= new ParameterEvent();
		
		/**
		 * 	@internal
		 */
		public var property:String;
		
		/**
		 * 	@public
		 */
		public var name:String;
		
		/**
		 * 	@public
		 */
		public var type:String;
		
		/**
		 * 	@internal
		 */
		public var target:Object;
		
		/**
		 * 	@public
		 */
		public var definition:ParameterDefinition;
		
		/**
		 * 	@public
		 */
		public var flags:uint;
		
		/**
		 * 	@protected
		 */
		protected const dispatcher:EventDispatcher	= new EventDispatcher();
		
		/**
		 * 	@protected
		 */
		internal var bindings:Vector.<ParameterBinding>;
		
		/**
		 * 	@constructor
		 */
		CONFIG::DEBUG public function Parameter():void {
			GC.watch(this);
		}
		
		/**
		 *	@internal
		 */
		batchass_ns function initialize(target:Object, definition:ParameterDefinition):void {
			
			this.target			= target;
			this.definition		= definition;
			this.type			= definition.type;
			this.name			= definition.name;
			
		}
		
		/**
		 * 	@public
		 */
		final public function listen(callback:Function, value:Boolean):void {
			if (value) {
				dispatcher.addEventListener(ParameterEvent.CHANGE, callback);
			} else {
				dispatcher.removeEventListener(ParameterEvent.CHANGE, callback);
			}
		}
		
		/**
		 * 	@public
		 */
		final public function addBinding(binding:ParameterBinding):void {
			bindings.push(binding);
		}
		
		/**
		 * 	@public
		 */
		final public function removeBinding(binding:ParameterBinding):void {
			const index:int = bindings.indexOf(binding);
			CONFIG::DEBUG {
				if (!index === -1) {
					throw new Error('not part');
					return;
				}	
			}
			bindings.splice(index, 1);	
		}
		
		/**
		 * 	@public
		 */
		public function set value(v:*):void {
			
			const old:*			= this.value;
			target[property]	= v;
			
			// we've changed
			dispatcher.dispatchEvent(CHANGE.dispatch(this, old));
			
		}
		
		/**
		 * 	@public
		 */
		public function display():String {
			return String(target[property]) || '';
		}
		
		/**
		 * 	@public
		 */
		public function get value():* {
			return target[property];
		}
		
		/**
		 * 	@public
		 */
		public function serialize():Object {
			return value;
		}
		
		/**
		 * 	@public
		 */
		public function unserialize(token:*):void {
			value = token;
		}
		
		/**
		 * 	@public
		 */
		public function reset():void {
			if (definition.reset !== undefined) {
				this.value = definition.reset;
			}
		}
		
		/**
		 * 	@public
		 */
		public function dispose():void {
			value = null;
		}
	}
}