////////////////////////////////////////////////////////////////////
///EMAQ Design
///http://www.emaqdesign.com
///Copyright (c) 2008-2011, EMAQ Design.
///All rights reserved.
///Redistribution and re-sale of these Flash Components/photo
///galleries+CMS systems/video loops, or related material, with or
///without modification, is not permitted.
/////////////////////////////////////////////////////////////////////

package
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.net.*;
	import flash.text.*;
	import flash.utils.*;
	
	import resolumeCom.*;
	import resolumeCom.events.*;
	import resolumeCom.parameters.*;

	//public class ResolumeTwitterBoxes extends Sprite movieclip?
	public class ResolumeTwitterBoxes extends Sprite
	{
		private var textTimer:Timer = new Timer(30000);  /// this is the timer for tweet refresh NOTE! Can't request more than 150 tweets an hour, so doing one req. per minute to be safe
		//// xml data
		private var xmlData;

		private var theTweetIndex:XMLList;
		/// twitter data
		public var _user1:String = "batchass";
		
		private var format1:TextFormat = new TextFormat();
		
		/// dynamic formatting vars
		private var theFontStyle = "Gotham Ultra";
		private var theFontSize = 14;
		private var theLetterSpacing = 1;
		private var theFontColor = "0xFF3333"; 
		private var theFontLeading:Number = 0;  /// unfortunately, you can't set leading to a negative value programmatically so this is limited

		// font array
		private var fontArray:Array = ["Arial","DIN-Regular","Rosewood Std","Gotham Ultra","Impact", "Differentia","Mesquite Std Medium","OCR A Std","ITC Lubalin Graph Std Demi","Stencil Std Bold","Silom"];
		
		public var numTextBoxes:Number = 5; /// number of text boxes in the MC
		//
		public var theNodeCounter:Number = 0;
		
		private var theScrollSpeed:Number = 10;
		//create the resolume object
		private var resolume:Resolume = new Resolume();
		
		//create as many different parameters as you like
		private var rtxt:StringParameter = resolume.addStringParameter("@NAME", "batchass");
		private var scrollSpeedSlider:FloatParameter = resolume.addFloatParameter("Scroll Speed", 0.5);
		private var fontSizeSlider:FloatParameter = resolume.addFloatParameter("Font Size", 0.15);
		private var fontStyleSlider:FloatParameter = resolume.addFloatParameter("Font Style" , 0.75);
		private var fontSpacingSlider:FloatParameter = resolume.addFloatParameter("Tracking" , 0.25);
		private var fontLeadingSlider:FloatParameter = resolume.addFloatParameter("Leading" , 0.25);
		private var label:TextField = new TextField(); 
		
		private var textToType:String	= '';
		private var timer:Timer	= new Timer(60);
		private var typeIndex:int = 0;
		
		public function ResolumeTwitterBoxes()
		{
			loadXML(); /// load XML
			initFormatting();
			//set callback, this will notify us when a parameter has changed
			resolume.addParameterListener(parameterChanged);
			textTimer.addEventListener(TimerEvent.TIMER, changeText);
			textTimer.start();
			addChild(label);
		}
		
		//// define formatting
		private function initFormatting():void
		{
			format1.font = theFontStyle;
			format1.bold = true;
			format1.size = theFontSize;
			format1.letterSpacing = theLetterSpacing;
			format1.color = theFontColor; 
			format1.leading = theFontLeading;
			format1.align = "center";
			///
		}
		
		//this method will be called everytime you change a paramater in Resolume
		public function parameterChanged(event:ChangeEvent): void
		{
			if (event.object == this.rtxt)
			{	
				_user1 = this.rtxt.getValue();
				loadXML();
			} 
			else if(event.object == this.scrollSpeedSlider)
			{
				theScrollSpeed = Math.round(this.scrollSpeedSlider.getValue() * 100);
				stage.frameRate = theScrollSpeed;
				
			} 
			else if(event.object == fontStyleSlider)
			{
				theFontStyle = fontArray[Math.round(this.fontStyleSlider.getValue() * 10)];
				initFormatting();
				updateText(null);
				
			} 
			else if(event.object == fontLeadingSlider)
			{
				theFontLeading = Math.round(this.fontLeadingSlider.getValue() * 100);
				initFormatting();
				updateText(null);
				
			} 
			else if(event.object == this.fontSpacingSlider)
			{
				theLetterSpacing = Math.round(this.fontSpacingSlider.getValue() * 50);
				initFormatting();
				updateText(null);
				
			} 
			else if(event.object == this.fontSizeSlider) 
			{
				theFontSize = Math.round(this.fontSizeSlider.getValue() * 100);
				initFormatting();
				updateText(null);			
			}
		}
		
		/// parse XML
		private function loadXML():void
		{
			//// loads a twitter feed according
			//// to a user name set in Resolume
			var loader:URLLoader = new URLLoader();
			/// can't use a try/catch since it executes faster than a loader works
			/// so use an IO error checker to load a placeholder xml file if the internet is down
			loader.addEventListener(IOErrorEvent.IO_ERROR, catchIOError); 
			loader.addEventListener(Event.COMPLETE, parseXML);
			// loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, SecurityError);
			// var urlReq = new URLRequest("xml/twitterPlaceHolder.xml");
			var urlReq:URLRequest = new URLRequest("http://twitter.com/statuses/user_timeline/" + _user1 + ".xml?count=1"); /// gets particular user tweets
			loader.load(urlReq);
		}
		private function catchIOError(e:Event)
		{
			trace("Twitter feed Not Available" + e);
			var loader:URLLoader = new URLLoader();
			var urlReq = new URLRequest("xml/twitterPlaceHolder.xml");
			loader.load(urlReq);
			loader.addEventListener(Event.COMPLETE, parseXML);
		}
		/// populate the drop down lists
		private function parseXML(event:Event):void
		{
			xmlData = new XML(event.target.data);
			
			/// build the tweet xml list
			theTweetIndex = xmlData.status.text; //// returns all texts 
			// theTweetIndex = xmlData.status.user.name; //// returns all names 
			// theTweetIndex = xmlData.status.user.id; //// returns all ids 
			
			updateText(null);
			//start
			textToType = theTweetIndex[0];
			timer.addEventListener(TimerEvent.TIMER, _onTimer);
			timer.start();
			
			label.width = 500;
			label.autoSize = TextFieldAutoSize.CENTER;
			label.setTextFormat(format1); 
			label.wordWrap = true;		
		}
		private function _onTimer(event:TimerEvent):void 
		{
			label.text = textToType.substr(0, ++typeIndex);
			label.setTextFormat(format1); 
			trace("typeIndex: "+typeIndex+" textToType.length: "+textToType.length);
			if (typeIndex >= textToType.length) 
			{
				trace("typeIndex: "+typeIndex+" textToType.length: "+textToType.length);
				timer.removeEventListener(TimerEvent.TIMER, _onTimer);
				timer.stop();
			}
		}
		private function updateText(e:Event):void
		{
			label.setTextFormat(format1);
		}
		
		public function changeText(e:Event):void
		{
			loadXML();			
		}
		//// various PARAMS
		/*		
		http://search.twitter.com/search.atom?q=flashbrighton – all tweets mentioning “flashbrighton”
		http://search.twitter.com/search.atom?q=from%3Azenbullets – all tweets from user “zenbullets”
		http://search.twitter.com/search.atom?q=flashbrighton+from%3Azenbullets – all tweets from user “zenbullets” that refer to “flashbrighton”
		*/
		//// end class
	}
	
	//// end package
}