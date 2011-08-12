package resolume.parameter {
	
	import flash.events.*;
	import flash.utils.*;
	
	import resolume.core.*;
	import resolume.event.*;
	//import resolume.util.*;
	
	use namespace parameter;
	use namespace batchass_ns;
	
	dynamic final public class ParameterList {
		
		/**
		 * 	@private
		 */
		private var parameters:Vector.<Parameter>;
		
		/**
		 * 	@public
		 */
		batchass_ns function attach(list:Vector.<Parameter>):void {
			
			for each (var parameter:Parameter in list) {
				this[parameter.name] = parameter;
			}
			this.parameters = list;
		}
		
		/**
		 * 	@public
		 */
		public function unserialize(token:Object):Boolean {
			
			for (var i:String in token) {
				var param:Parameter = this[i];
				if (!param) {
					
					//Console.Log(Console.ERROR, i, 'does not exist!');
					
					CONFIG::DEBUG { throw new Error(i + 'does not exist!'); }
					
					continue;
				}
				param.unserialize(token[i]);
			}
			
			return true;
		}
		
		/**
		 * 	@public
		 */
		public function serialize():Object {
			
			if (parameters.length) {
				
				const serialized:Object = {};
				for each (var parameter:Parameter in parameters) {
					serialized[parameter.name] = parameter.serialize();
				}
				return serialized;	
			}
			
			return null;
		}
		
		/**
		 * 	@public
		 */
		public function get iterator():Vector.<Parameter> {
			return this.parameters;
		}
		
		/**
		 * 	@public
		 */
		public function dispose():void {
			for each (var parameter:Parameter in this) {
				delete this[parameter.name];
			}
			parameters = null;
		}
		
		/**
		 * 	@public
		 */
		CONFIG::DEBUG public function toString():String {
			return '[ParameterList:\n\t' + parameters.join('\n\t') + ']';
		}
	}
}