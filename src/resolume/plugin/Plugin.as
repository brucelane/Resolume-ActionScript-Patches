package resolume.plugin {
	
	import flash.display.*;
	import flash.utils.*;
	
	import resolume.core.*;
	import resolume.display.*;
	
	// plugin type registration
	final public class Plugin {
		
		// public
		public static const UNKNOWN:int							= -1;
		
		/**
		 * 	@public
		 */
		public static const MODULE:int							= 0;	// in memory running plugins
		// public static const INTERFACE:int						= 1;	// modules, dispatches interface events ????????????????
		public static const SFILTER:int							= 1;	// surface filters
		public static const SGENERATOR:int						= 2;	// surface generators
		public static const SBLENDMODE:int						= 3;	// surface mixers
		public static const PLAYMODE:int						= 4;	// time playmode
		public static const MACRO:int							= 5;	// keyboard macro
		public static const PROTOCOL:int						= 6;	// protocols
		
		/**
		 * 	@public
		 */
		public static const INITIALIZE_FAILURE:int				= 0;
		public static const INITIALIZE_DISABLED:int				= 0;
		public static const INITIALIZE_SUCCESS:int				= 1;
		public static const INITIALIZE_ASYNCHRONOUS:int			= 2;
		
		// flag for whether or not the filter should only be rendered when the layer is rendered
		public static const FILTER_FRAMERATE_ADAPTIVE:uint		= 0x00;
		public static const FILTER_FRAMERATE_FULL:uint			= 0x01;
		
		// flag -- filter forces layer to be rendered every frame
		public static const FILTER_MUTED:uint					= 0x10;
		
		// flag -- generator can be scrubbed
		public static const GENERATOR_SCRUBBABLE:uint			= 0x01;
		
		// flag -- generator has time
		public static const GENERATOR_TIME:uint					= 0x02;
		
	}
}