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
	import flash.events.*;
	import flash.net.*;
	import flash.utils.*;
	import flash.text.*;
	
	//import the Resolume communication classes
	import resolumeCom.*;
	import resolumeCom.parameters.*;
	import resolumeCom.events.*;
	
	
	
	public class ResolumeTwitterScroll extends MovieClip{
		/// text vars
		private var numTextBoxes:Number = 4;
		private var format1:TextFormat = new TextFormat();
		
		/// dynamic formatting vars
		private var theFontStyle = "Gotham Ultra";
		private var theFontSize = 36;
		private var theLetterSpacing = 1;
		private var theFontColor = "0x000000"; 
		private var theFontLeading:Number = 3; /// unfortunately, you can't set leading to a negative value programmatically so this is limited
		private var theScrollSpeed:Number = 10;
		
		// font array
		private var fontArray:Array = ["Arial","DIN-Regular","Rosewood Std","Gotham Ultra","Impact", "Differentia","Mesquite Std Medium","OCR A Std","ITC Lubalin Graph Std Demi","Stencil Std Bold","Silom"];
		
		//
		private var textTimer:Timer = new Timer(60000);  /// this is the timer for tweet refresh 
		// NOTE! Can't request more than 150 tweets an hour, so doing one req. per minute to be safe
		private var frameTimer:Timer = new Timer(theScrollSpeed);  /// this is the timer for scroll speed
		private var xmlData;
		/// private var theXMLPath:String = "xml/xmlTwitter.xml";
		private var theTweetIndex:XMLList;
		/// twitter data
		public var _user1:String = "DimancheRouge";
		//
		public var theNodeCounter:Number = 0;
		//create the resolume object that will do all the hard work for you
		private var resolume:Resolume = new Resolume();
		//create interface objects for resolume
		private var rtxt:StringParameter = resolume.addStringParameter("@Name", "batchass");
		private var scrollSpeedSlider:FloatParameter = resolume.addFloatParameter("Scroll Speed", 0.5);
		private var fontSizeSlider:FloatParameter = resolume.addFloatParameter("Font Size", 0.25);
		private var fontStyleSlider:FloatParameter = resolume.addFloatParameter("Font Style" , 0.5);
		private var fontSpacingSlider:FloatParameter = resolume.addFloatParameter("Tracking" , 0.25);
		private var fontLeadingSlider:FloatParameter = resolume.addFloatParameter("Leading" , 0.25);
		
		public function ResolumeTwitterScroll():void{
			///
			initFormatting();
			initTextBoxes();
			//set callback, this will notify us when resolume text is changed
			resolume.addParameterListener(parameterChanged);
			textTimer.addEventListener(TimerEvent.TIMER, changeText);
			frameTimer.addEventListener(TimerEvent.TIMER, doNextFrame);
			
			textTimer.start();
		}
		
		//// define formatting
		private function initFormatting():void{
			format1.font = theFontStyle;
			format1.bold = true;
			format1.size = theFontSize;
			format1.letterSpacing = theLetterSpacing;
			format1.color = theFontColor; 
			format1.leading = theFontLeading;
			format1.align = "center";
			
			///
		}
		
		///////////////////////////////////////////
		//// spawn text boxes into the text holders
		/////////////////////////////////////////////
		public function initTextBoxes():void{
			for(var i:Number = 0; i <= numTextBoxes; i++){
				///// add text boxes
				//// make sure they're empty
				var theBodyText:TextField = new TextField();
				theBodyText.htmlText = "";
				theBodyText.embedFonts = true;
				theBodyText.name = "theBodyText";
				theBodyText.type = TextFieldType.DYNAMIC;
				theBodyText.border = false;
				theBodyText.autoSize = TextFieldAutoSize.CENTER; // this
				// theBodyText.width = 500;
				theBodyText.wordWrap = true;
				theBodyText.antiAliasType = AntiAliasType.ADVANCED;
				
				theBodyText.y = 5; // theBodyText.height/2; // -10;
				theBodyText.x -= theBodyText.width/2;
				/*var theTextHolder = mctxt.getChildByName("mctxtsub" + i);
				// theBodyText.width = theTextHolder.textBground.width;
				theTextHolder.addChild(theBodyText);*/
				theBodyText.name = "theBodyText";
				theBodyText.setTextFormat(format1);
				//theBodyText.width = theTextHolder.textBground.width;
				
			}
			/// now that the boxes are built, we can load XML from query string 
			loadXML(); 
			// frameTimer.start();
		}
		
		
		/////////////////////////////////
		//// MAKE THE TWITTER QUERY ///////
		//this method will be called everytime you change a paramater in Resolume
		//////////////////////////////////////
		public function parameterChanged(event:ChangeEvent): void{
			if (event.object == this.rtxt){	
				_user1 = this.rtxt.getValue();
				loadXML();
			} else if(event.object == fontStyleSlider){
				theFontStyle = fontArray[Math.round(this.fontStyleSlider.getValue() * 10)];
				initFormatting();
				//fontSizeDisplay.text = theFontStyle + " " + Math.round(this.fontStyleSlider.getValue() * 10);// 
				updateText(null);
				
			} else if(event.object == this.scrollSpeedSlider){
				theScrollSpeed = Math.round(this.scrollSpeedSlider.getValue() * 1000);
				stage.frameRate = theScrollSpeed;
				
				
			} else if(event.object == fontLeadingSlider){
				theFontLeading = Math.round(this.fontLeadingSlider.getValue() * 100);
				//fontSizeDisplay.text = String(theFontLeading);
				initFormatting();
				updateText(null);
				
			} else if(event.object == this.fontSpacingSlider){
				theLetterSpacing = Math.round(this.fontSpacingSlider.getValue() * 50);
				initFormatting();
				updateText(null);
			}else if(event.object == this.fontSizeSlider) {
				theFontSize = Math.round(this.fontSizeSlider.getValue() * 100);
				initFormatting();
				updateText(null);
				
			}
		}
		
		/////////////////////////////
		///// parse XML for list date info
		/////////////////////////////
		private function loadXML():void{
			//// this should change depending on the setting set in Resolume!
			var loader:URLLoader = new URLLoader();
			/// can't use a try/catch since it executes faster than a loader works
			/// so use an IO error checker to load a placeholder xml file if the internet is down
			loader.addEventListener(IOErrorEvent.IO_ERROR, catchIOError); 
			loader.addEventListener(Event.COMPLETE, parseXML);
			// var urlReq = new URLRequest("xml/twitterPlaceHolder.xml");
			var urlReq:URLRequest = new URLRequest("http://twitter.com/statuses/user_timeline/" + _user1 + ".xml?count=5"); /// gets particular user tweets
			loader.load(urlReq);
		}
		//
		private function catchIOError(e:Event){
			trace("Twitter feed Not Available" + e);
			var loader:URLLoader = new URLLoader();
			var urlReq = new URLRequest("xml/twitterPlaceHolder.xml");
			loader.load(urlReq);
			loader.addEventListener(Event.COMPLETE, parseXML);
		}
		
		/// populate the lists
		private function parseXML(event:Event):void{
			xmlData = new XML(event.target.data);
			
			/// build the tweet xml list
			theTweetIndex = xmlData.status.text; //// returns all texts 
			// theTweetIndex = xmlData.status.user.name; //// returns all names 
			// theTweetIndex = xmlData.status.user.id; //// returns all ids 
			///// populate names
			updateText(null);
		}
		
		private function changeText(e:Event):void{
			
			loadXML();
		}
		
		private function updateText(e:Event):void{
			//twatMC.alpha = 0;
			//// clear all the text fields
			for(var i:Number = 0; i <= numTextBoxes; i++){
				/*var theTextMC = mctxt.getChildByName("mctxtsub" + i);
				var theTextBox = theTextMC.getChildByName("theBodyText");
				
				
				var fck = String(theTweetIndex[theNodeCounter]);
				theTextBox.text = "";
				theTextBox.text = theTweetIndex[theNodeCounter];
				theTextBox.setTextFormat(format1);
				theTextBox.y = 0-theTextBox.height/2;
				theTextBox.x = 0-theTextBox.width/2;
				*/
				
				// trace("nodeCounter1: " + theNodeCounter)
				if(theNodeCounter >= theTweetIndex.length()-1){
					theNodeCounter = 0;
				} else {
					theNodeCounter++
				}
			}
			
		}
		private function doNextFrame(e:Event):void{
			
			//mctxt.nextFrame();
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