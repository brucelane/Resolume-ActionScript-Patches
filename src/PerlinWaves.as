/**
 * Copyright Aquioux ( http://wonderfl.net/user/Aquioux )
 * MIT License ( http://www.opensource.org/licenses/mit-license.php )
 * Downloaded from: http://wonderfl.net/c/rqm1
 */

package {
	/**
	 * perlin waves(mouse move reaction)
	 * @author YOSHIDA, Akio (Aquioux)
	 * @see http://wonderfl.net/c/7D0s (perlin waves)
	 * @see http://wonderfl.net/c/jvIs (perlinNoise, mouse move reaction)
	 */
	//import aquioux.display.colorUtil.CycleRGB;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.BlurFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import resolumeCom.*;
	import resolumeCom.events.*;
	import resolumeCom.parameters.*;
	
	[SWF(width = "640", height = "480", frameRate = "30", backgroundColor = "#000000")]
	public class PerlinWaves extends Sprite {
		
		// ã‚¹ãƒ†ãƒ¼ã‚¸ã‚µã‚¤ã‚ºé–¢ä¿‚
		private const SW:int = stage.stageWidth;
		private const SH:int = stage.stageHeight;
		private const CX:Number = SW / 2;
		private const CY:Number = SH / 2;
		
		
		// perlinNoise é–¢ä¿‚
		private var perlinBmd_:BitmapData;
		private var perlinBm_:Bitmap;
		
		private const PERLIN_WIDTH:int  = 31;
		private const PERLIN_HEIGHT:int = 31;
		
		//private var offsets_:Array = [new Point(), new Point(), new Point(), new Point()];
		private var offsets_:Array = [new Point(), new Point()];
		private const OCTAVES:uint = offsets_.length;
		
		private var isDisp:Boolean = false;
		
		
		// ç·šæç”»é–¢ä¿‚
		private var lineCanvas_:Shape;
		
		private const INTERVAL_WIDTH:Number  = SW / (PERLIN_WIDTH - 1);
		private const INTERVAL_HEIGHT:Number = 0xFF / SH;
		private const INTERVAL_COLOR:Number  = 360 / PERLIN_HEIGHT;
		
		private var g_:Graphics;
		private var colors_:Vector.<uint>;
		
		
		// è¡¨ç¤ºé–¢ä¿‚
		private var viewBmd_:BitmapData;
		
		private const RECT:Rectangle = new Rectangle(0, 0, SW, SH);
		private const ZERO_POINT:Point = new Point();
		private const BLUR:BlurFilter = new BlurFilter(16, 16, BitmapFilterQuality.HIGH);
		private const COLOR_TRANS:ColorTransform = new ColorTransform(1, 1, 1, 0.25);
		
		private var mx:int = 0;
		private var my:int = 0;
		private var resolume:Resolume = new Resolume();
		private var xSlider:FloatParameter = resolume.addFloatParameter("x speed", 0.5);
		private var ySlider:FloatParameter = resolume.addFloatParameter("y speed", 0.5);
		
		// ã‚³ãƒ³ã‚¹ãƒˆãƒ©ã‚¯ã‚¿
		public function PerlinWaves() {
			setup();
			addEventListener(Event.ENTER_FRAME, update);
			//stage.addEventListener(MouseEvent.CLICK, clickHandler);
		}
		
		// ã‚»ãƒƒãƒˆã‚¢ãƒƒãƒ—
		private function setup():void {
			// perlinNoise ç”¨ BitmapData ç”Ÿæˆ
			perlinBmd_ = new BitmapData(PERLIN_WIDTH, PERLIN_HEIGHT, false, 0x000000);
			perlinBm_  = new Bitmap(perlinBmd_);
			addChild(perlinBm_);
			
			clickHandler(null);
			
			// è¡¨ç¤ºç”¨ BitmapData ç”Ÿæˆ
			viewBmd_ = new BitmapData(SW, SH, true, 0xFF000000);
			addChild(new Bitmap(viewBmd_));
			
			// ç·šæç”»ã‚«ãƒ³ãƒã‚¹ç”Ÿæˆ
			lineCanvas_ = new Shape();
			g_ = lineCanvas_.graphics;
			
			// ç·šè‰²è¨­å®š
			colors_ = new Vector.<uint>();
			var angle:Number = 0;
			for (var i:int = 0; i < PERLIN_HEIGHT; i++) {
				colors_.push(CycleRGB.getColor(angle));
				angle += INTERVAL_COLOR;
			}
			colors_.fixed = true;
			resolume.addParameterListener(parameterChanged);
		}
		//this method will be called everytime you change a paramater in Resolume
		public function parameterChanged(event:ChangeEvent): void
		{
			if(event.object == this.xSlider) 
			{
				mx = Math.round(this.xSlider.getValue() * SW);
			}
			else if(event.object == this.ySlider) 
			{
				my = Math.round(this.ySlider.getValue() * SH);
			}
		}		
		
		// ã‚¢ãƒƒãƒ—ãƒ‡ãƒ¼ãƒˆ
		private function update(e:Event):void {
			updatePerlinNoise();
			updateLines();
			updateView();
		}
		// perlinNoise ã®æ›´æ–°
		private function updatePerlinNoise():void {
			// offsets_ ã®æ›´æ–°
			var offsetX:Number = (mx / CX - 1) * 0.5;
			var offsetY:Number = (my / CY - 1) * 0.5;
			offsets_[0].x += offsetX;
			offsets_[0].y += offsetY;
			offsets_[1].x -= offsetX;
			offsets_[1].y -= offsetY;
			//offsets_[2].x += offsetX;
			//offsets_[2].y -= offsetY;
			//offsets_[3].x -= offsetX;
			//offsets_[3].y += offsetY;
			// perlinNoise ã??æ??æ??
			perlinBmd_.perlinNoise(PERLIN_WIDTH, PERLIN_HEIGHT, OCTAVES, 0xFF, true, true, 1, true, offsets_);
		}
		// ç?šã??æ??æ??
		private function updateLines():void {
			g_.clear();
			for (var h:int = 0; h < PERLIN_HEIGHT; h++) {
				g_.moveTo(-20, h);
				g_.lineStyle(0, colors_[h], 1);
				for (var w:int = 0; w < PERLIN_WIDTH; w++) {
					var value:Number = (perlinBmd_.getPixel(w, h) & 0xFF) / INTERVAL_HEIGHT;
					g_.lineTo(w * INTERVAL_WIDTH, value);
				}
			}
		}
		// è??ç?ºã??æ??æ??
		private function updateView():void {
			viewBmd_.lock();
			viewBmd_.fillRect(RECT, 0xFF000000);
			viewBmd_.draw(lineCanvas_);
			viewBmd_.applyFilter(viewBmd_, RECT, ZERO_POINT, BLUR);
			viewBmd_.draw(lineCanvas_,null,COLOR_TRANS);
			viewBmd_.unlock();
		}
		
		private function clickHandler(e:MouseEvent):void {
			perlinBm_.visible = isDisp;
			isDisp = !isDisp;
		}
	}
}


//package aquioux.display.colorUtil {
/**
 * ã??ã?µã??ãƒ?ã??ãƒ?ãƒ?ã??è??ç??ç??çš?ã?ª RGB ã??è??ç??
 * @author Aquioux(YOSHIDA, Akio)
 */
/*public*/ class CycleRGB {
	/**
	 * 32bit ã??ãƒ?ãƒ?ã??ã?Ÿã??ã??ã??ãƒ?ãƒ?ã??å??
	 */
	static public function get alpha():uint { return _alpha; }
	static public function set alpha(value:uint):void {
		_alpha = (value > 0xFF) ? 0xFF : value;
	}
	private static var _alpha:uint = 0xFF;
	
	private static const PI:Number = Math.PI;        // å??å??çŽ?
	private static const DEGREE90:Number  = PI / 2;    // 90åº?ï??å??åº?æ??å??å??ï??
	private static const DEGREE180:Number = PI;        // 180åº?ï??å??åº?æ??å??å??ï??
	
	/**
	 * è??åº?ã??å?œã??ã?Ÿ RGB ã??å??ã??
	 * @param    angle    HSV ã??ã??ã??ã??è??åº?ï??åº?æ??æ??ï??ã??æŒ?å?š
	 * @return    è??ï??0xNNNNNNï??
	 */
	public static function getColor(angle:Number):uint {
		var radian:Number = angle * PI / 180;
		var valR:uint = (Math.cos(radian)             + 1) * 0xFF >> 1;
		var valG:uint = (Math.cos(radian + DEGREE90)  + 1) * 0xFF >> 1;
		var valB:uint = (Math.cos(radian + DEGREE180) + 1) * 0xFF >> 1;
		return valR << 16 | valG << 8 | valB;
	}
	
	/**
	 * è??åº?ã??å?œã??ã?Ÿ RGB ã??å??ã??ï??32bit ã??ãƒ?ãƒ?ï??
	 * @param    angle    HSV ã??ã??ã??ã??è??åº?ï??åº?æ??æ??ï??ã??æŒ?å?š
	 * @return    è??ï??0xNNNNNNNNï??
	 */
	public static function getColor32(angle:Number):uint {
		return _alpha << 24 | getColor(angle);
	}
	
}

//}
