package resolume.parameter {
	
	/**
	 * 	@dynamic!
	 */
	dynamic public class ParameterDefinition {
		
		public var name:String;
		public var type:String;
		public var target:String;
		
		public var children:Vector.<ParameterDefinition>;
		
		/**
		 * 	@constructor
		 */
		public function ParameterDefinition(name:String = null, type:String = null, target:String = null, alt:Object = null):void {
			
			this.name		= name;
			this.type		= type;
			this.target		= target;
			
			if (alt) {
				for (var i:String in alt) {
					this[i] = alt[i];
				}
			}
		}
		
		/**
		 * 	@public
		 */
		CONFIG::DEBUG public function toString():String {
			var out:String = '[ParameterDef name=' + name + ', target=' + target + ', type=' + type;
			for (var i:String in this) {
				out += ' ' + i + '=' + this[i];
			}
			return out + ']';
		}
	}
}