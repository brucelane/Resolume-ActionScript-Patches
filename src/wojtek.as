/**
 * Copyright wojtek ( http://wonderfl.net/user/wojtek )
 * MIT License ( http://www.opensource.org/licenses/mit-license.php )
 * Downloaded from: http://wonderfl.net/c/5zAF
 */

// forked from hacker_mejum_45's forked from: ã®ã‚“ã³ã‚Šçœºã‚ã‚‹ç”¨
// forked from keno42's ã®ã‚“ã³ã‚Šçœºã‚ã‚‹ç”¨
// forked from keno42's ã²ã¾ã‚ã‚Šã£ã½ã„ã‚„ã¤
// è§’åº¦ã®é»„é‡‘æ¯”åˆ†å‰²ã¨ã‹ å‡ºå±• - Nature by Number http://www.etereaestudios.com/movies/nbyn_movies/nbyn_mov_youtube.htm
package 
{
	import flash.display.*;
	import flash.events.*;
	import flash.filters.*;
	import flash.geom.*;
	import flash.utils.*;
	import resolumeCom.*;
	import resolumeCom.events.*;
	import resolumeCom.parameters.*;
	public class wojtek extends Sprite 
	{
		private const WIDTH:int = 640;
		private const HEIGHT:int = 480;
		private var MAX_NUM:int = 1800;
		private var num:int = MAX_NUM;
		private var delay:int = 50;
		private var gv:Number = 0;
		private var ga:Number = 0;
		private var angle:Number = 0;
		private var firstP:Particle = new Particle();
		private var lastP:Particle = firstP;
		private var bmpData:BitmapData = new BitmapData(WIDTH,HEIGHT,false,0);
		private var timer:Timer = new Timer(delay);
		
		private var resolume:Resolume = new Resolume();
		private var xSlider:FloatParameter = resolume.addFloatParameter("x", 0.5);
		private var ySlider:FloatParameter = resolume.addFloatParameter("y", 0.5);
		private var delaySlider:FloatParameter = resolume.addFloatParameter("delay", 0.5);
		//button
		private var switchEvent:EventParameter = resolume.addEventParameter("Switch!");
		private var _mx:int = WIDTH/2;
		private var _my:int = HEIGHT/2;

		public function wojtek() {
			// write as3 code here..
			trace("e");
			//addEventListener(Event.ENTER_FRAME, onEnterFrame);
			addChild( new Bitmap( bmpData ) );
			shoot(firstP, angle);
			timer.addEventListener(TimerEvent.TIMER, onTimer);
			stage.addEventListener(MouseEvent.CLICK, onClick);
			timer.start();
			resolume.addParameterListener(parameterChanged);
		}
		private function onClick(e:MouseEvent):void{
			randomRefresh();
		}
		
		private function randomRefresh():void{
			if( num != 0 ) return;
			var tempNum:int = MAX_NUM; 
			var p:Particle = firstP;
			var angleDiff:Number = Math.random() * Math.PI * 2;
			var rBase:int = Math.random() * 0xFF;
			var gBase:int = Math.random() * 0xFF;
			var bBase:int = Math.random() * 0xFF;
			var rGoal:int = Math.random() * 0xFF;
			var gGoal:int = Math.random() * 0xFF;
			var bGoal:int = Math.random() * 0xFF;
			
			angle = 0;
			do {
				tempNum--;
				angle += angleDiff;
				p.toX = _mx + Math.sqrt(tempNum) * Math.cos(angle) / (MAX_NUM / 9000);
				p.toY = _mx + Math.sqrt(tempNum) * Math.sin(angle) / (MAX_NUM / 9000);
				p.color = 
					Math.floor(rBase + ( (rGoal-rBase) * tempNum / MAX_NUM )) << 16 |
					Math.floor(gBase + ( (gGoal-gBase) * tempNum / MAX_NUM )) << 8 |
					Math.floor(bBase + ( (bGoal-bBase) * tempNum / MAX_NUM ));
			} while( p = p.next );
		}
		private function onTimer(e:Event):void
		{
			var p:Particle = firstP;
			bmpData.lock();
			do {
				p.update();

				bmpData.setPixel(p.x, p.y, p.color);
			} while( p = p.next )
			bmpData.applyFilter(bmpData,bmpData.rect,new Point(),new BlurFilter(2,2));
			bmpData.unlock();
			if( num > 0 ){
				for( var i:int = 0; i < gv; i++ ){
					num--;
					var temp:Particle = new Particle();
					angle += Math.PI * 137.5077 / 180;
					shoot(temp, angle);
					lastP.next = temp;
					lastP = temp;
					if( num == 0 ) break;
				}
				gv += ga; 
				ga += 0.02;
			}
		}
		private function shoot(p:Particle, angle:Number):void{
			p.x = 280;
			p.y = 180;
			p.toX = 320 + Math.sqrt(num) * Math.cos(angle) / (MAX_NUM / 9000);
			p.toY = 180 + Math.sqrt(num) * Math.sin(angle) / (MAX_NUM / 9000);
			p.color = 
				(0xCC + Math.ceil( 0x33 - 0x33 * num / MAX_NUM )) << 16 |
				(0x88 + Math.ceil( 0x77 - 0x77 * num / MAX_NUM )) << 8 |
				(Math.ceil( 0x44 * num / MAX_NUM ));
		}
		//this method will be called everytime you change a paramater in Resolume
		public function parameterChanged(event:ChangeEvent): void
		{
			if(event.object == this.xSlider) 
			{
				_mx = this.xSlider.getValue() * WIDTH;
			}
			else if(event.object == this.ySlider) 
			{
				_my = this.ySlider.getValue() * HEIGHT;
			}
			else if(event.object == this.switchEvent) 
			{
				randomRefresh();
			}
			else if(event.object == this.delaySlider) 
			{
				delay = this.delaySlider.getValue() * 1000;
				timer.delay = delay;
			}
		}
	}
}

final class Particle
{
	public var x:Number;
	public var y:Number;
	public var toX:uint;
	public var toY:uint;
	public var color:uint;
	public var next:Particle;
	public function update():void{
		x += 0.1 * (toX-x);
		y += 0.1 * (toY-y);
	}
}