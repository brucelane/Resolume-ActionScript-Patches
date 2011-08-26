/**
 * Copyright foR ( http://wonderfl.net/user/foR )
 * MIT License ( http://www.opensource.org/licenses/mit-license.php )
 * Downloaded from: http://wonderfl.net/c/krPA
 */

// forked from flashhawkmx's ColorfulLine
package  
{
	import flash.display.Bitmap;
	import flash.display.BlendMode;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	/**
	 * @author flashhawk
	 * blog http://www.flashquake.cn
	 */
	[SWF(backgroundColor="#000000", width="465", height="465", frameRate="30")]
	
	public class ColorfulLine extends Sprite 
	{
		public var particles : Array = [];
		public var lineCanvas : Sprite;
		private var blurBmd : CanvasBitmapData;
		private var blurBmp : Bitmap;
		
		private var matrix : Matrix = new Matrix();
		
		private var r : Number = 255; 
		private var g : Number = 127; 
		private var b : Number = 0; 
		
		private var ri : Number = 0.02;
		private var gi : Number = 0.015; 
		private var bi : Number = 0.025; 
		
		public function ColorfulLine()
		{
			matrix.scale(0.1, 0.1);
			this.addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e : Event) : void
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			lineCanvas = new Sprite();
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			this.addEventListener(Event.ENTER_FRAME, loop);
			stage.addEventListener(Event.RESIZE, initBitmapCanvas);
			initBitmapCanvas();
		}
		
		private function loop(e:Event) : void
		{
			
			var color : uint = 0xFFFFFF;
			
			//var color : uint = (Math.sin(r += ri) * 128 + 127) << 16 | (Math.sin(g += gi) * 128 + 127) << 8 | (Math.sin(b += bi) * 128 + 127) ;
			lineCanvas.graphics.clear();
			lineCanvas.graphics.lineStyle(2, color);
			var prevMid : Point = null;
			
			
			for(var i : int = 1;i < particles.length;i++)
			{
				var pt1 : Point = new Point();
				var pt2 : Point = new Point();
				pt1.x = particles[i - 1].x;
				pt1.y = particles[i - 1].y;
				pt2.x =particles[i].x;
				pt2.y = particles[i].y;
				var midPoint : Point = new Point((pt1.x + pt2.x) / 2, (pt1.y + pt2.y) / 2);
				
				if(prevMid!=null)
				{
					lineCanvas.graphics.moveTo(prevMid.x, prevMid.y);
					lineCanvas.graphics.curveTo(pt1.x, pt1.y, midPoint.x, midPoint.y);
				}
				else
				{
					lineCanvas.graphics.moveTo(pt1.x, pt1.y);
					lineCanvas.graphics.lineTo(midPoint.x, midPoint.y);
				}
				prevMid = midPoint;
				
			}
			
			for(var j : int = 0;j < particles.length;j++)
			{
				var p : Particle = Particle(particles[j]);
				
				if(p.life < 0)
				{
					var index:int=particles.indexOf(p);
					particles.splice(index, 1);
				}
				p.update();
			}
			
			blurBmd.draw(lineCanvas, null, null, BlendMode.ADD);
			blurBmd.blur(2, 2, 1);
			blurBmd.colorMod(-5, -5, -5, 0);
		}
		
		private function initBitmapCanvas(e : Event = null) : void
		{
			if(blurBmd != null)blurBmd.dispose();
			if(blurBmp != null)removeChild(blurBmp);
			blurBmd = new CanvasBitmapData(stage.stageWidth * 0.5, stage.stageHeight * 0.5);
			blurBmp = new Bitmap(blurBmd);
			blurBmp.width = stage.stageWidth;
			blurBmp.height = stage.stageHeight;
			addChildAt(blurBmp, 0);
		}
		
		private function mouseMoveHandler(e : MouseEvent) : void
		{
			particles.push(new Particle(mouseX*0.5, mouseY*0.5, 30));
		}
	}
}

import flash.display.BitmapData;
import flash.filters.BlurFilter;
import flash.geom.ColorTransform;
import flash.geom.Point;

class Particle
{
	private var _x : Number;
	private var _y : Number;
	private var _life : int;
	private var xv : Number = 0;
	private var yv : Number = 0;
	private var f : Number = 0.1;
	
	public function Particle(x : Number,y : Number,life : Number = Infinity)
	{
		this._x = x;
		this._y = y;
		this._life = life;
	}
	
	public function update() : void
	{
		yv += (1 - Math.random() * 2);
		xv += (1 - Math.random() * 2);
		_x += xv;
		_y += yv;
		xv *= (1 - f);
		yv *= (1 - f);
		_life--;
	}
	
	public function get life() : int
	{
		return _life;
	}
	
	public function get x() : Number
	{
		return _x;
	}
	
	public function get y() : Number
	{
		return _y;
	}
}

class CanvasBitmapData extends BitmapData
{    
	private var bgColor : uint;
	
	public function CanvasBitmapData(width : Number, height : Number ,transparent : Boolean = false,color : uint = 0x000000) : void
	{
		this.bgColor = color;
		super(width, height, transparent, color);
	}
	
	public function blur( amountX : uint, amountY : uint, quality : uint ) : void
	{
		applyFilter(this, this.rect, new Point(), new BlurFilter(amountX, amountY, quality));
	}
	
	public function colorMod( red : int, green : int, blue : int, alpha : int ) : void
	{
		colorTransform(rect, new ColorTransform(1, 1, 1, 1, red, green, blue, alpha));
	}
	
	public function clear() : void
	{
		
		fillRect(rect, bgColor);
	}
}
