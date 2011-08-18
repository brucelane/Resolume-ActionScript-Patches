/**
 * Copyright rettuce ( http://wonderfl.net/user/rettuce )
 * MIT License ( http://www.opensource.org/licenses/mit-license.php )
 * Downloaded from: http://wonderfl.net/c/oDyE
 */

package 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.InterpolationMethod;
	import flash.display.MovieClip;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import resolumeCom.*;
	import resolumeCom.events.*;
	import resolumeCom.parameters.*;
	[SWF(backgroundColor = 0x000000, frameRate = 60)]
	
	/**
	 * ...
	 * @author rettuce
	 * 
	 * èŠ±ã³ã‚‰ã‚’ãƒ‘ãƒ©ãƒ¡ãƒ¼ã‚¿ã§ç”Ÿæˆ
	 * ãƒ‘ãƒ©ãƒ¡ãƒ¼ã‚¿ã«ã‚ˆã£ã¦èŠ±ã®æœ€çµ‚å½¢ãŒå¤‰åŒ–
	 * 
	 */
	public class DrawFlower extends MovieClip 
	{
		
		/* Property */
		/////////////////////////////////////////////////////////////////////////
		
		private var resolume:Resolume = new Resolume();
		private var _slider1:FloatParameter = resolume.addFloatParameter("a", 0.5);
		private var _slider2:FloatParameter = resolume.addFloatParameter("b", 0.5);
		private var _slider3:FloatParameter = resolume.addFloatParameter("c", 0.5);
		private var _slider4:FloatParameter = resolume.addFloatParameter("d", 0.5);
		private var _slider5:FloatParameter = resolume.addFloatParameter("e", 0.5);
		private var _slider6:FloatParameter = resolume.addFloatParameter("f", 0.5);	
		
		
		/* Main Function */
		/////////////////////////////////////////////////////////////////////////ã€€
		
		public function DrawFlower()
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init );
		}
		
		private function init(e:Event = null ):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init );
			setStage();
			UIset();
			
			flowerInit();
			
			resolume.addParameterListener(parameterChanged);

			loaderInfo.addEventListener(Event.UNLOAD, function(e:Event):void {
				stage.removeEventListener(Event.RESIZE, resizeEvent);
				loaderInfo.removeEventListener(Event.UNLOAD, arguments.callee );
			});
		}
		private function UIset():void{
			/*_slider1 = new HUISlider(this, 0, 10, "Parameter", paramHandler);
			_slider2 = new HUISlider(this, 0, 25, "Parameter", paramHandler);
			_slider3 = new HUISlider(this, 0, 40, "Parameter", paramHandler);
			_slider4 = new HUISlider(this, 0, 55, "Parameter", paramHandler);
			_slider5 = new HUISlider(this, 0, 70, "Parameter", paramHandler);
			_slider6 = new HUISlider(this, 0, 85, "Parameter", paramHandler);
			_radioOUT = new RadioButton(this, 10, 105, "ON",  false, onSelect);
			_radioIN  = new RadioButton(this, 50, 105, "OFF", true, onSelect);*/
		}
		private function parameterChanged(e:ChangeEvent):void
		{
			/*if(e.object == this._slider1) 
			{
				NUM = (this._slider1.getValue() *  100 /4)+5; 
			}*/
			switch(e.object){
				case _slider1:
					NUM = Math.round(this._slider1.getValue() * 100 /4)+5;    // 0 - 25 + 5            
					break;
				case _slider2:
					W = Math.round(this._slider2.getValue() * 100*2.5);    // 0 - 100 * 2.5    
					break;
				case _slider3:
					H = Math.round(this._slider3.getValue() * 100*0.6)+10;    // 0 - 60 +10            
					break;
				case _slider4:
					FY = this._slider4.getValue() * 100*0.005+0.5;    // 0 - 0.5 + 0.5            
					break;
				case _slider5:
					FT = this._slider5.getValue() * 100*0.004+0.3;    // 0 - 0.4 + 0.3            
					break;
				case _slider6:
					K = Math.round(this._slider6.getValue() * 100*0.4)+10;    // 0 - 40 +10            
					break;
			}
			setPetal();
		}        
		        
		
		private var _flower:Sprite;
		private var _pArr:Array = [];
		private var W:uint = 180;    //å¹…
		private var H:uint = 30;    //é«˜ã•
		private var K:uint = 20;    //æ·±ã•
		private var FY:Number = 0.7;    //è†¨ã‚‰ã¿ä½ç½® æ¨ª
		private var FT:Number = 0.5;    //è†¨ã‚‰ã¿ä½ç½® ç¸¦
		private var NUM:uint = 10;    // æžšæ•°
		
		private var fillFlg:Boolean = true;
		
		private function flowerInit():void
		{
			_flower = new Sprite();
			_flower.x = stage.stageWidth/2;
			_flower.y = stage.stageHeight/2;
			addChild(_flower);
			
			setPetal();
		}
		
		private function setPetal():void
		{
			if(!fillFlg){
				_flower.graphics.clear();
				_flower.graphics.lineStyle( 3, 0x000000 );                
			}else{
				_flower.graphics.clear();
				
				var fillType:String = GradientType.RADIAL;
				var colors:Array = [0x99F900, 0xF2C24A, 0x99FFCC];
				var alphas:Array = [1, 1, 1];
				var ratios:Array = [2, 127, 255];
				var matrix:Matrix = new Matrix();
				matrix.createGradientBox(-W*2, -W*2, 0, W, W );
				_flower.graphics.beginGradientFill(fillType, colors, alphas, ratios, matrix);                
			}
			var petal:Sprite;
			for(var i:int=0; i < NUM; i++){
				var ang:Number = ( 2*Math.PI/NUM*i - Math.PI/2 );
				drawPetal(ang);
			}
			
			if(fillFlg){
				_flower.graphics.beginFill(0xFFFFFF);
				_flower.graphics.lineStyle(W/50, 0x99F900 );
				_flower.graphics.drawCircle(0, 0, W/20);
			}
			
			var filArr:Array = new Array();
			var dsFilter:DropShadowFilter = new DropShadowFilter(0, 45, 0x999999, 0.3, 5, 5 );
			filArr.push(dsFilter);
			_flower.filters = filArr;
		}
		
		private function drawPetal(ang:Number):void
		{
			var _g:Graphics = _flower.graphics;
			var pointArr:Array = [];
			var px:Number;
			var py:Number
			
			var x1:Number = W*FY/2;
			var x2:Number = W*FY;
			var x3:Number = W;
			var x4:Number = W-K;
			var y1:Number = H*FT;
			var y2:Number = H;
			var y3:Number = H*FT/2;
			var y4:Number = 0;
			
			var leng1:Number = Math.sqrt( x1*x1 + y1*y1 );
			var leng2:Number = Math.sqrt( x2*x2 + y2*y2 );
			var leng3:Number = Math.sqrt( x3*x3 + y3*y3 );
			var leng4:Number = Math.sqrt( x4*x4 + y4*y4 );
			
			var ang1:Number = y1/leng1;
			var ang2:Number = y2/leng2;
			var ang3:Number = y3/leng3;
			var ang4:Number = y4/leng4;
			
			pointArr.push(new Point(0, 0));
			pointArr.push( new Point( Math.cos(ang-ang1)*leng1 , Math.sin(ang-ang1)*leng1 ));
			pointArr.push( new Point( Math.cos(ang-ang2)*leng2 , Math.sin(ang-ang2)*leng2 ));
			pointArr.push( new Point( Math.cos(ang-ang3)*leng3 , Math.sin(ang-ang3)*leng3 ));            
			
			_g.moveTo(pointArr[0].x, pointArr[0].y);
			for(var i:int=0; i<pointArr.length-1; i++){
				px = (pointArr[i+1].x + pointArr[i].x)/2;
				py = (pointArr[i+1].y + pointArr[i].y)/2;                
				_g.curveTo(pointArr[i].x, pointArr[i].y, px, py);
			}
			_g.lineTo(pointArr[pointArr.length-1].x, pointArr[pointArr.length-1].y );
			
			_g.lineTo( Math.cos(ang+ang4)*leng4 , Math.sin(ang+ang4)*leng4 );
			_g.lineTo( Math.cos(ang+ang3)*leng3 , Math.sin(ang+ang3)*leng3 );
			
			pointArr = [];
			pointArr.push( new Point( Math.cos(ang+ang3)*leng3 , Math.sin(ang+ang3)*leng3 ));            
			pointArr.push( new Point( Math.cos(ang+ang2)*leng2 , Math.sin(ang+ang2)*leng2 ));
			pointArr.push( new Point( Math.cos(ang+ang1)*leng1 , Math.sin(ang+ang1)*leng1 ));
			pointArr.push(new Point(0, 0));
			
			_g.moveTo(pointArr[0].x, pointArr[0].y);
			for(i=0; i<pointArr.length-1; i++){
				px = (pointArr[i+1].x + pointArr[i].x)/2;
				py = (pointArr[i+1].y + pointArr[i].y)/2;                
				_g.curveTo(pointArr[i].x, pointArr[i].y, px, py);
			}
			_g.lineTo(pointArr[pointArr.length-1].x, pointArr[pointArr.length-1].y );
		}
		
		private function angleMath($x:Number, $y:Number):Number
		{
			var dx:Number = $x - $x;
			var dy:Number = $y - 0;
			return Math.atan2(dy , dx)*180/Math.PI;
		}
		
		
		
		
		
		/* Setter & Getter */
		/////////////////////////////////////////////////////////////////////////
		
		
		/* Stage Setting & Re_size Event */
		/////////////////////////////////////////////////////////////////////////ã€€
		
		private function setStage():void {
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.addEventListener(Event.RESIZE, resizeEvent);
			resizeHandler();
		}
		private function resizeEvent(e:Event = null):void {
			resizeHandler();
		}        
		public function resizeHandler():void {
			
		}
		
	}
	
}