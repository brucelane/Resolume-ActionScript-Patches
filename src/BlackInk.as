/**
 * Copyright monodreamer ( http://wonderfl.net/user/monodreamer )
 * MIT License ( http://www.opensource.org/licenses/mit-license.php )
 * Downloaded from: http://wonderfl.net/c/6xjV
 */

package {
	import flash.filters.DisplacementMapFilter;
	import flash.filters.DisplacementMapFilterMode;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.display.BitmapData;
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.filters.BlurFilter;
	import flash.display.BlendMode;
	import resolumeCom.*;
	import resolumeCom.events.*;
	import resolumeCom.parameters.*;
	
	[SWF(width = "640", height = "480", frameRate = "60", backgroundColor = "0xffffff")]
	public class BlackInk extends Sprite {
		
		private const WIDTH:int = 640;
		private const HEIGHT:int = 480;

		public var emitter:Emitter;
		
		public var canvas:BitmapData;
		public var buffer:BitmapData;
		
		private var iParticles:uint = 0;
		private var particlesLength:uint = 0;
		
		private var console:Console;
		
		private var blurFilter:BlurFilter;
		private var blurFilter2:BlurFilter;
		private var ct:ColorTransform = new ColorTransform(1, 1, 1, .9);
		private var _rect:Rectangle;
		private var _ep:Point = new Point;
		private var _mx:int, _my:int;

		private var resolume:Resolume = new Resolume();
		private var xSlider:FloatParameter = resolume.addFloatParameter("x", 0.5);
		private var ySlider:FloatParameter = resolume.addFloatParameter("y", 0.5);

		public function BlackInk() {
			// write as3 code here..
			//emitter = new Emitter();
			//emitter = new Emitter(0,0,0,0,0,0,.9,.9,1,8,30,120,60,-0.3);
			emitter = new Emitter(0,0,0,0,0,0,.9,.9,1,2,30,80,60,-0.3);
			
			canvas = new BitmapData(640, 480, true, 0x00000000);
			buffer = new BitmapData(640, 480, true, 0x00000000);
			
			_rect = canvas.rect;
			
			var map:BitmapData = new BitmapData(640, 480);
			map.perlinNoise(84, 84, 5, Math.random()*100, false, true, 1, true);
			var bmp:Bitmap = new Bitmap(buffer);
			bmp.filters = [new DisplacementMapFilter(map, _ep, 1, 1, 64, 64, DisplacementMapFilterMode.CLAMP)];
			addChild(bmp);
			
			blurFilter = new BlurFilter(2, 2, 1);
			blurFilter2 = new BlurFilter(4, 4, 1);
			
			_mx = stage.stageWidth/2;
			_my = stage.stageHeight/2;
			
			/*
			stage.addEventListener(MouseEvent.MOUSE_MOVE, function(e:MouseEvent):void
			{
				e.updateAfterEvent();
				_mx = stage.mouseX;
				_my = stage.mouseY;
				//emitter.emit();
			});
			*/
			resolume.addParameterListener(parameterChanged);
			
			addEventListener(Event.ENTER_FRAME,function(e:Event):void
			{
				emitter.x = _mx;
				emitter.y = _my;
				emitter.emit();
				
				// console.clear();
				// console.log('update');
				
				// console.log('previous Particles:' + String(emitter.particles.length));
				
				emitter.update();
				
				//  console.log('current Particles:' + String(emitter.particles.length));
				
				particlesLength = emitter.particles.length;
				
				//canvas.lock();
				//canvas.fillRect(_rect, 0x0);
				//canvas.applyFilter( canvas, canvas.rect, canvas.rect.topLeft, blurFilter );
				var p:Particle;
				for(iParticles = 0; iParticles < particlesLength; iParticles++)
				{
					p = emitter.particles[iParticles];
					var r:Number = p.lifeTime / p.maxLifeTime;
					//canvas.setPixel32(p.x, p.y, r * 255 << 24 | 255 << 16 | r * r * 255 << 8 | r * r * r * r * 255);
					canvas.setPixel32(p.x, p.y, r*0xff << 24 |(canvas.getPixel32(p.x, p.y)&0xff000000) );
					//canvas.setPixel32(emitter.particles[iParticles].x, emitter.particles[iParticles].y, r * 255 << 24 | 255 << 16 | 255 << 8 | 255);
					//canvas.setPixel32(emitter.particles[iParticles].x, emitter.particles[iParticles].y, 0xFFFFFFFF);
				}
				canvas.applyFilter( canvas, _rect, _ep, blurFilter );
				//canvas.unlock();
				buffer.lock();
				buffer.applyFilter( buffer, _rect, _ep, blurFilter2 );
				buffer.colorTransform(_rect, ct);
				// buffer.draw(canvas, null, null, BlendMode.ADD);
				buffer.copyPixels(canvas, _rect, _ep, null, null, true);
				buffer.unlock();
			});
			
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
		}	
	}
}
import flash.display.AVM1Movie;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.display.BitmapData;
import flash.events.Event;
import flash.events.EventDispatcher;
class Emitter extends EventDispatcher {
	
	public var x:Number;
	public var y:Number;
	public var vx:Number = 0;
	public var vy:Number = 0;
	public var ivx:Number;
	public var ivy:Number;
	public var px:Number;
	public var py:Number;
	public var pvx:Number;
	public var pvy:Number;
	public var pax:Number;
	public var pay:Number;
	public var prx:Number;
	public var pry:Number;
	public var particles:Vector.<Particle>;
	public var lifeTime:uint;
	public var lifeTimeRandom:int;
	public var amounts:uint;
	public var motionInfluence:Number;
	
	public var explosion:Number;
	public var vibration:Number;
	
	public var velocityMin:Number = 0;
	
	public var nozzle:BitmapData;
	
	public var nozzleType:String = 'TRAIL';
	
	//private var trailNozzle:Vector.<EmitPoint>;
	private var trailNozzle:Array;
	
	public function Emitter(x:Number = 0, y:Number = 0, pvx:Number = 0, pvy:Number = 0, pax:Number = 0, pay:Number = 0, prx:Number = 1.0, pry:Number = 1.0, explosion:Number = 0.0, vibration:Number = 0.0, amounts:uint = 1, lifeTime:uint = 1, lifeTimeRandom:int = 0, motionInfluence:Number = 0.0)
	{
		this.x = this.px = x;
		this.y = this.py = y;
		this.pvx = pvx;
		this.pvy = pvy;
		this.pax = pax;
		this.pay = pay;
		this.prx = prx;
		this.pry = pry;
		this.explosion = explosion;
		this.vibration = vibration;
		this.lifeTime = lifeTime;
		this.amounts = amounts;
		this.motionInfluence = motionInfluence;
		this.lifeTimeRandom = lifeTimeRandom;
		particles = new Vector.<Particle>();
		
		nozzle = new BitmapData(100,100);
		
		//trailNozzle = new Vector.<EmitPoint>
		trailNozzle = [];
	}
	
	private var iEmit:uint = 0;
	
	private var r:Number = 0;
	private var evx:Number = 0;
	private var evy:Number = 0;
	private var vibx:Number = 0;
	private var viby:Number = 0;
	private var rv:Number = 0;
	private var ta:Number = 0;
	
	private var e:Number = 0;
	private var ttx:Number = 0;
	private var tty:Number = 0;
	
	private var ti:Number = 0;
	private var tj:Number = 0;
	
	private var lx:Number = 0;
	private var ly:Number = 0;
	
	private var sx:Number = 0;
	private var sy:Number = 0;
	
	private var tvx:Number = 0;
	private var tvy:Number = 0;
	
	private var tmpx:Number = 0;
	private var tmpy:Number = 0;
	private var tmpP:uint = 0;
	
	public function emit():void
	{
		tvx = x - px;
		tvy = y - py;
		//vx,vy not correct?
		ivx = tvx * motionInfluence;
		ivy = tvy * motionInfluence;
		
		ta = amounts;//(Math.sqrt(vx * vx + vy * vy) > velocityMin) ? amounts : 0;
		
		//Make Trail Nozzle Vector
		//tvx = x - px;
		//tvy = y - py;
		
		lx = tvx>0 ? tvx : -tvx;//Math.abs(tvx);
		ly = tvy>0 ? tvy : -tvy;//Math.abs(tvy);
		
		sx = (lx) ? tvx/lx : 1;
		sy = (ly) ? tvy/ly : 1;
		
		ttx = lx*lx;//2 * lx;
		tty = ly*ly;//2 * ly;
		
		ti = 1;
		tj = 0;
		
		if(lx >= ly)
		{
			// trailNozzle = new Vector.<EmitPoint>(lx,true);
			trailNozzle = new Array(lx);
			e = lx;
			
			for(ti; ti <= lx; ti++)
			{
				e += tty;
				if(e >= ttx)
				{
					tj++;
					e = e - ttx;
				}
				trailNozzle[ti-1] = new EmitPoint(sx * ti, sy * tj);
			}
		}
		else
		{
			//trailNozzle = new Vector.<EmitPoint>(ly,true);
			trailNozzle = new Array(ly);
			e = ly;
			
			for(ti; ti <= ly; ti++)
			{
				e += ttx;
				if(e >= tty)
				{
					tj++;
					e = e - tty;
				}
				trailNozzle[ti-1] = new EmitPoint(sx * tj, sy * ti);
			}
		}
		
		var l:int = trailNozzle.length-1;
		for(iEmit = 0; iEmit < ta; iEmit++)
		{
			r =  PI2 * iEmit / amounts;
			evx = Math.cos(r) * explosion;
			evy = Math.sin(r) * explosion;
			
			r = PI2 * Math.random();//360 * Math.random() * Math.PI / 180
			rv = vibration * Math.random();
			
			vibx = rv * Math.sin(r);           
			viby = rv * Math.cos(r);
			
			if(l> 0)
			{
				tmpP = l * Math.random();
				//trailNozzle[0];
				tmpx = trailNozzle[tmpP].x + px;
				tmpy = trailNozzle[tmpP].y + py;
			}
			else
			{
				tmpx = x;
				tmpy = y;
			}
			particles.push(new Particle(tmpx, tmpy, pvx + ivx + evx + vibx , pvy + ivy + evy + viby, pax, pay, prx, pry, lifeTime - int(Math.random() * lifeTimeRandom)));
			
			//particles.push(new Particle(x, y, pvx + ivx + evx + vibx , pvy + ivy + evy + viby, pax, pay, prx, pry, lifeTime - int(Math.random() * lifeTimeRandom)));
			
			//particles.push(new Particle(int(nozzle.width * Math.random()) + x, (nozzle.height * Math.random()) + y, pvx + ivx + evx + vibx , pvy + ivy + evy + viby, pax, pay, prx, pry, lifeTime - int(Math.random() * lifeTimeRandom)));
		}          
	}
	
	private const PI2:Number = 2*Math.PI;
	private var iUpdate:int = 0;
	private var pLength:int = 0;
	public function update():void
	{
		vx = x - px;
		vy = y - py;
		px = x;
		py = y;
		
		pLength = particles.length;
		if(pLength == 0) return;
		
		iUpdate = pLength - 1;
		var p:Particle;
		do
		{
			p = particles[iUpdate];
			p.vx += p.ax;
			p.vx *= p.rx;
			p.x += p.vx;
			
			p.vy += p.ay;
			p.vy *= p.ry;
			p.y += p.vy;
			
			if(p.lifeTime <= 0)
			{
				particles.splice(iUpdate,1);
				continue;
			}
			p.lifeTime--;
		}
		while(iUpdate--);
	}
}

class EmitPoint {
	public var x:int;
	public var y:int;
	
	public function EmitPoint(x:int = 0, y:int = 0)
	{
		this.x = x;
		this.y = y;
	}
}

class Particle {
	
	public var x:Number;
	public var y:Number;
	public var vx:Number;
	public var vy:Number;
	public var ax:Number;
	public var ay:Number;
	public var rx:Number;
	public var ry:Number;
	public var maxLifeTime:uint;
	public var lifeTime:uint;
	
	public function Particle(x:Number = 0, y:Number = 0, vx:Number = 0, vy:Number = 0, ax:Number = 0, ay:Number = 0, rx:Number = 1.0, ry:Number = 1.0, lifeTime:uint = 1)
	{
		this.x = x;
		this.y = y;
		this.vx = vx;
		this.vy = vy;
		this.ax = ax;
		this.ay = ay;
		this.rx = rx;
		this.ry = ry;
		this.lifeTime = this.maxLifeTime =  lifeTime;
	}
}

import flash.text.TextField;
import flash.events.Event;
class Console extends TextField
{
	public function Console()
	{
		text = '';
		selectable = false;
		textColor = 0xFFFFFF;
		addEventListener(Event.ADDED_TO_STAGE, function(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, arguments.callee);
			width = stage.stageWidth;
			height = stage.stageHeight;
			
		});
	}
	
	public function log(message:String):void
	{
		this.appendText(message + '\n');
	}
	
	public function clear():void{
		this.text = '';
	}
	
}
