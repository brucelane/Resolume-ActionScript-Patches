package resolume.parameter {
	
	/*
	
	Keyboard:	type = 0
	Midi and keyboard both use one 4 byte integer for bindings
	Midi uses first 2 bytes
	Keyboard second 2 bytes
	
	0xMMMMKKKK
	
	KEYBOARD
	0xF000	= KeyLocation
	0x0F00	= KeyModifier (ALT, SHIFT, CONTROL)
	0x00FF	= KeyCode	0-255
	
	*/
	
	final public class ParameterBinding {
		
		/**
		 * 	@public
		 */
		public static const BINDING_KEY:uint	= 0x00;
		public static const BINDING_MIDI:uint	= 0x01;
		
		/**
		 * 	@public
		 */
		public var type:uint;
		
		/**
		 * 	@public
		 */
		public var control:uint;
		
		/**
		 * 	@public
		 */
		public function unserialize(token:Object):void {
			type	= token.type;
			control	= token.control;
		}
		
		/**
		 * 	@public
		 */
		public function serialize():Object {
			return {
				type:		type,
				control:	control
			};
		}
	}
}