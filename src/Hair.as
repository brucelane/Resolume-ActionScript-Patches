// I translated and modified this from Don Relyea's Open Frameworks Hair Particle Drawing Project:
// http://www.donrelyea.com/hair_particle_drawing_OF.htm
// www.donrelyea.com
// July 22 2008

package {
	
	// Import Adobe classes.
	import flash.display.*;
	import flash.events.*;
	import flash.net.URLRequest;
	import flash.text.*;
		
	/**
	 * Description goes here.
	 * @class			Hair
	 * @author			
	 * @date			25.11.2008
	 * @version			0.1
	 **/
	public class Hair extends MovieClip {
		
		public static const CLASS_NAME:String = "Hair";
		
		//private var vt:VerboseTrace;
		//private var em:EventManager;
		
		private var _hairs:Array;
		private var _canvasBD:BitmapData;
		private var _sourceBD:BitmapData;
		private var _count:uint;
		private var _angle:uint;
		
		
		
		/**
		 * Constructor.
		 * @param		verbosity	int. Optional, defaults to 0. The verbosity level.
		 **/
		public function Hair() {
			init();
		}
		
		public override function toString():String {
			return CLASS_NAME + " >> ";
		}
		
		
		
		// INITIALIZATION ============================================================================================================
		private function init():void {
			var loader:Loader = new Loader;
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, gotImage);
			loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler ) ; 
			loader.load (
				new URLRequest("gravias.jpg")
			);
			
			
		}
		private function ioErrorHandler( event:IOErrorEvent ):void
		{
			trace( 'An IO Error has occured: ' + event.text );
		} 
		private function gotImage (e:Event):void 
		{
			createVars();
			createChildren();
			initButtons();
			initEvents();
		}
		private function createVars():void 
		{
			_hairs = [];
			_count = 250;
			_angle = 0;
			
			_canvasBD = new BitmapData(800, 400, false, 0x00000000);
			this.addChild( new Bitmap( _canvasBD ));
			//this.x = this.y = 30;
			_sourceBD = new SourceBD(0, 0);
			var circle:Sprite = new Circle();
			
			
			var i:int;
			for (i = 0; i < _count; i++) {
				var particle:HairParticle = new HairParticle(circle);
				
				generate(particle);
				_hairs.push( particle );
			}
		}
		
		private function createChildren():void {
		}
		
		private function initButtons():void {
		}
		
		private function initEvents():void {
			addEventListener(Event.ENTER_FRAME,			draw);
		}
		
		
		
		
		// ACTIONS ===================================================================================================================
		
		/**
		 * draw.
		 * @description	
		 **/
		private function draw( evt:Event=null ) : void {
			_canvasBD.lock();
			for each (var particle:HairParticle in _hairs) {
				if (particle.active) {
					particle.draw(_canvasBD);
				} else {
					generate(particle);
					
				}
				
			}
			_canvasBD.unlock();
		}
		
		/**
		 * generate.
		 * @description	
		 **/
		private function generate(particle:HairParticle) : void {
			
			var r:int = 35;
			// var x:uint = mouseX - r + Math.random() * r * 2;
			// var y:uint = mouseY - r + Math.random() * r * 2;
			
			var x:Number = Math.random() * _sourceBD.width;
			var y:Number = Math.random() * _sourceBD.height;
			
			var color:uint = _sourceBD.getPixel(x, y);
			_angle += .2;
			
			particle.activate( Math.random() * 255, Math.random() * 1, x, y, color, _angle );
		}
		
		
		// SETTERS AND GETTERS =======================================================================================================
		
		
		
		// EVENTS ====================================================================================================================
		
		
		
		// ANIMATION ====================================================================================================================
		
		
		
		
	}
	
}
