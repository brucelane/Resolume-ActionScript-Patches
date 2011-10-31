/**
 * Copyright wonderwhyer ( http://wonderfl.net/user/wonderwhyer )
 * MIT License ( http://www.opensource.org/licenses/mit-license.php )
 * Downloaded from: http://wonderfl.net/c/zBu2
 */

package  
{

    import flash.display.Loader;
    import flash.display.LoaderInfo;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.MouseEvent;
    
    import resolumeCom.*;
    import resolumeCom.events.*;
    import resolumeCom.parameters.*;
    
    /**
    * MP3 Loading based on this code:
    * http://code.google.com/p/makc/source/browse/trunk/flash/fp10_fft/ClientMP3Loader.as
    */
	[SWF(width='640', height='480', frameRate='30', backgroundColor='0')]
    public class MusicAtom extends Sprite 
	{
		//create the resolume object
		private var resolume:Resolume = new Resolume();
		//sliders
		private var iSlider:FloatParameter = resolume.addFloatParameter("intensity", 0.5);
        //public var fr:FileReference;
        public var visualizer:Visualizer;
        
        public function MusicAtom() {
            addEventListener(Event.ENTER_FRAME,update);
            visualizer = new Visualizer();
            addChild(visualizer);
			resolume.addParameterListener(parameterChanged);
        }
        
        public function update(e:Event):void {
                   visualizer.update();
        }
        
        public function up(e:Event):void 
		{
                visualizer.clean();
        }
		public function parameterChanged(event:ChangeEvent): void
		{
			visualizer.intensity = Math.round(this.iSlider.getValue()*40);
			
		}
    }
}
import flash.display.BlendMode;
import flash.display.Graphics;
import flash.geom.Rectangle;
import flash.filters.BlurFilter;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.ColorTransform;
import flash.utils.ByteArray;
import flash.display.Sprite;


class Dot 
{
    public var x:Number;
    public var y:Number;
    public var dx:Number = 0;
    public var dy:Number = 0;
    public var direction:Number;
    public var color:uint = 0;
    public var alpha:Number = 0;
    
    public function Dot(x:Number,y:Number,direction:Number) {
        this.x = x;
        this.y = y;
        this.direction = direction;
    }

}

class Visualizer extends Sprite
{
    private var xx:Number;
    private var yy:Number;
    private var direction:Number = 0;
    private var color:Number = 0;
    private var view:BitmapData;
    private var bmp:Bitmap;
    public var c:uint=0;
    public var steps:uint = 8;
    public var sp:Sprite;
    public var dots:Vector.<Dot>;
    public var bf:BlurFilter = new BlurFilter(1.5,1.5,1);
	public var intensity:Number = 2;
        
    public function Visualizer()
    {
        view = new BitmapData(450,450,false,0);
        bmp = new Bitmap(view);
        addChild(bmp);
        bmp.x=0;
        bmp.y=0;
        xx = view.width/2;
        yy = view.height/2;
        dots = new Vector.<Dot>();
        for(var i:uint=0;i<steps;i++)
        {
            dots.push(new Dot(0,0,Math.random()*Math.PI*2));
        }
        sp = new Sprite();
    }
    
    public function update():void 
	{
        var spVal:Number;
        var i:uint;
        var inRe:Vector.<Number> = new Vector.<Number>();
        var g:Graphics = sp.graphics;
        c++;
        if(c%20==0){
            var ct:ColorTransform = new ColorTransform(1,1,1,0.999);
            view.colorTransform(view.rect,ct);
        }
        var halfPos:uint = 64;//wave.length/2;
		var wave1:Vector.<Number> = new Vector.<Number>;
        for(i=0;i<256;i++)
        {
			wave1.push(Math.random()*intensity);
        }     
        
        var part:uint = 256/steps;
        var shift:uint = 600/(steps+1);
        var pow:Number = -1.8;
        
        for(var j:uint=0;j<steps;j++)
		{
            var m:Number = (Math.pow(j+1,pow)+0.004)*10;
            var dot:Dot = dots[j];
            dot.alpha*=0.5;
            var d:Number = Math.sin(dot.y*0.05);
            var xx:Number = view.width/2+Math.sin(dot.x*0.05)*200*d;
            var yy:Number = view.height/2+Math.cos(dot.x*0.05)*200*d;
            g.clear();
            g.moveTo(xx,yy);
            for(i=1;i<part;i++)
            {
                spVal = wave1[i]/m;				
                dot.alpha = dot.alpha*0.9 + Math.min(1,Math.abs(spVal*0.5))*0.1;
                dot.direction+=spVal*0.1;
                dot.x+=Math.sin(dot.direction);//*0.5;
                dot.y+=Math.cos(dot.direction);//*0.5;
                g.lineStyle(dot.alpha*0.5,HSLtoRGB(1,dot.direction*4,1,0.0001+dot.alpha*0.5));
                d = Math.sin(dot.y*0.05);
                xx = view.width/2+Math.sin(dot.x*0.05)*200*d;
                yy = view.height/2+Math.cos(dot.x*0.05)*200*d;
                g.lineTo(xx,yy);
            }
            view.draw(sp,null,null,BlendMode.ADD);
        }
        view.applyFilter(view,view.rect,view.rect.topLeft,bf);
    }
    
    public function clean():void
    {
        view.fillRect(view.rect,0);
        dots = new Vector.<Dot>();
        for(var i:uint=0;i<steps;i++)
        {
            dots.push(new Dot(0,0,Math.random()*Math.PI*2));
        }
    }
    
    private function HSLtoRGB(a:Number=1,hue:Number=0,saturation:Number=1,lightness:Number=0.5):uint
    {
        a = Math.max(0,Math.min(1,a));
        saturation = Math.max(0,Math.min(1,saturation));
        lightness = Math.max(0,Math.min(1,lightness));
        hue = hue%360;
        if(hue<0)hue+=360;
        hue/=60;
        var C:Number = (1-Math.abs(2*lightness-1))*saturation;
        var X:Number = C*(1-Math.abs((hue%2)-1));
        var m:Number = lightness-0.5*C;
        C=(C+m)*255;
        X=(X+m)*255;
        m*=255;
         if(hue<1) return (C<<16) + (X<<8) + m;
         if(hue<2) return (X<<16) + (C<<8) + m;
         if(hue<3) return (m<<16) + (C<<8) + X;
         if(hue<4) return (m<<16) + (X<<8) + C;
         if(hue<5) return (X<<16) + (m<<8) + C;
         return (C<<16) + (m<<8) + X;
    }
}