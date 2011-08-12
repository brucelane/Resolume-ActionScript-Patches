package resolume.plugin {
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	
	import resolume.core.*;
	import resolume.display.*;
	import resolume.event.*;
	import resolume.parameter.*;
	
	use namespace batchass_ns;
	
	public class Patch extends Sprite implements IParameterObject {
		
		/**
		 * 	@protected
		 */
		protected var data:Object;
		
		/**
		 *	@public
		 */
		protected var file:IFileReference;
		
		/**
		 * 	@protected
		 */
		protected const parameters:ParameterList	= new ParameterList();
		
		/**
		 * 	@public
		 */
		parameter const matrix:Matrix				= new Matrix();
		
		/**
		 * 	@protected
		 */
		protected var invalid:Boolean				= true;
		
		/**
		 * 	@protected
		 */
		protected var layer:IDisplayLayer;
		
		/**
		 * 	@protected
		 */
		protected var content:Object;
		
		/**
		 *	@public
		 */
		final public function setParameterValue(name:String, value:*):void {
			const p:Parameter	= parameters[name];
			if (!p) {
				CONFIG::DEBUG {
					throw new Error(name + ' Not Found.');
				}
			}
			p.value	= value;
		}
		
		/**
		 *	@public
		 */
		final public function getParameterValue(name:String):* {
			const p:Parameter	= parameters[name];
			if (!p) {
				CONFIG::DEBUG {
					throw new Error(name + ' Not Found.');
				}
			}
			return p.value;
		}
		
		/**
		 * 	@public
		 */
		public function setup(file:IFileReference, content:Object):void {
			this.file		= file;
			this.content	= content;
		}
		
		/**
		 * 	@public
		 */
		final public function getFile():IFileReference {
			return file;
		}
		
		/**
		 * 	@public
		 */
		final public function attach(list:Vector.<Parameter>):void {
			parameters.attach(list);
		}
		
		/**
		 * 	@public
		 */
		public function hasNewFrame():Boolean {
			return invalid;
		}
		
		/**
		 * 	@protected
		 */
		private function invalidated(event:Event = null):void {
			invalidate();
		}
		
		/**
		 * 	@public
		 */
		public function invalidate():void {
			invalid = true;
		}
		
		/**
		 * 	@public
		 */
		final public function getParameters():ParameterList {
			return parameters;
		}
		
		/**
		 * 	@public
		 */
		public function initialize(layer:IDisplayLayer, context:SurfaceContext):int {
			
			this.layer		= layer;
			
			// success
			return Plugin.INITIALIZE_SUCCESS;
		}
		
		/**
		 * 	@public
		 */
		final public function get id():String {
			return file.path;
		};
		
		/**
		 * 	@public
		 */
		final public function get path():String {
			return file.name.substr(0, file.name.lastIndexOf('.'));
		};
		
		/**
		 * 	@public
		 */
		override final public function get name():String {
			var name:String	= file.name;
			return name.substr(0, name.length - file.extension.length - 1);
		}
		
		/**
		 * 	@public
		 */
		public function unserialize(token:Object):Boolean {
			return true;
		}
		
		/**
		 * 	@public
		 */
		public function serialize():Object {
			return {
				url:		file.path,
					parameters:	parameters.serialize()
			};
		}
		
		/**
		 * 	@public
		 */
		public function dispose():void {
			
			// attach
			parameters.dispose();
			
		}
	}
}