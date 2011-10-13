/**
 * Copyright Glidias ( http://wonderfl.net/user/Glidias )
 * MIT License ( http://www.opensource.org/licenses/mit-license.php )
 * Downloaded from: http://wonderfl.net/c/fbYv
 */

/**
 ãƒ•ãƒ©ã‚¯ã‚¿ãƒ«ã§ç”»åƒã‚’æç”»
 
 ãƒ‘ã‚¯ãƒªå…ƒãƒã‚¿:
 fladdict Â» ã‚³ãƒ³ãƒ”ãƒ¥ãƒ¼ã‚¿ãƒ¼ã«çµµç”»ã‚’æã‹ã›ã‚‹
 http://fladdict.net/blog/2009/05/computer-painting.html
 
 æ¨™æº–åå·®ï¼š
 http://www.cap.or.jp/~toukei/kandokoro/html/14/14_2migi.htm
 
 ç”»åƒã®èª­ã¿è¾¼ã¿å‡¦ç†ï¼š
 http://wonderfl.kayac.com/code/3fb2258386320fe6d2b0fe17d6861e7da700706a
 
 RGB->HSBå¤‰æ›ï¼š
 http://d.hatena.ne.jp/flashrod/20060930#1159622027
 
 **/
package 
{
	import alternativa.engine3d.alternativa3d;
	import alternativa.engine3d.containers.KDContainer;
	import alternativa.engine3d.controllers.SimpleObjectController;
	import alternativa.engine3d.core.Camera3D;
	import alternativa.engine3d.core.Debug;
	import alternativa.engine3d.core.Face;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.Object3DContainer;
	import alternativa.engine3d.core.Vertex;
	import alternativa.engine3d.core.View;
	import alternativa.engine3d.core.Wrapper;
	import alternativa.engine3d.materials.FillMaterial;
	import alternativa.engine3d.materials.Material;
	import alternativa.engine3d.objects.Mesh;
	import alternativa.engine3d.objects.SkyBox;
	import alternativa.engine3d.primitives.Box;
	import alternativa.engine3d.primitives.Plane;
	
	import com.greensock.TweenLite;
	import com.greensock.easing.Cubic;
	import com.greensock.easing.Elastic;
	import com.greensock.easing.Linear;
	import com.greensock.plugins.HexColorsPlugin;
	import com.greensock.plugins.TweenPlugin;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	
	import resolume.asset.DimancheAfficheImage;
	
	use namespace alternativa3d;
	
	/**
	 * WIP: Real-time processed image using Alternativa3D's KDContainer to generate a "growing"  *  city.
	 * 
	 * Since image is used, can consider using perlin noise or other procedural means to 
	 * generate city layout.
	 * 
	 * I was thinking a Blade runner style city would be nice.
	 
	 *  W-S-A-D to fly around with mouse drag look.
	 * 
	 * @author Glidias
	 */
	[SWF(width = "640", height = "480", frameRate = "30", backgroundColor = "#ffffff")]
	
	public class DimancheAffiche extends Sprite 
	{
		static public const FLOOR_COLOR:uint = 0xAAAAAA;
		
		//æ¨™æº–åå·®ã®é–¾å€¤ã€‚å°ã•ãã™ã‚‹ã¨ç´°ã‹ããªã‚‹ã‘ã©ã€å°ã•ã™ãŽã‚‹ã¨ãŸã ã®ãƒ¢ã‚¶ã‚¤ã‚¯ã¿ãŸããªã‚‹ã€‚
		private const THRESHOLD:Number = 0.1;
		
		private var fillRectangleArray:Array;
		//private var image:Bitmap;
		private var imageData:BitmapData;
		private var _canvas:Sprite;
		
		private var camera:Camera3D;
		private var kdContainer:KDContainer;
		private var cameraController:SimpleObjectController;
		private var KD_NODE:Class;
		private var _lastKDNode:*;
		private static const WORLD_SCALE:Number = 128;
		private static const INV_255:Number = 1 / 255;
		private static const MAX_HEIGHT:Number = 12000;
		private var rootContainer:Object3DContainer;
		
		private var _tint:Number;
		
		//private var sourceBMP:BitmapData;
		
		public function DimancheAffiche():void 
		{
			TweenPlugin.activate( [HexColorsPlugin] );
			
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
			
			
			
			
		}
		
		private function init(e:Event = null):void 
		{
			imageData = new DimancheAfficheImage();
			
			initA3D(); 
			removeEventListener(Event.ADDED_TO_STAGE, init);
			//ã‚­ãƒ£ãƒ³ãƒã‚¹ç”¨ã‚¹ãƒ—ãƒ©ã‚¤ãƒˆ
			_canvas = new Sprite;
			
			var p:RectanglePiece = new RectanglePiece();
			var node:*;
			var threshold:Number = kdContainer.threshold;
			
			p.x0 = 0;
			p.y0 = 0;
			p.x1 = imageData.width;
			p.y1 = imageData.height;
			p.c = 0;
			
			// Setup root starting
			kdContainer.root = setupNode(p);
			kdContainer.boundMinX = 0;
			kdContainer.boundMinY = 0;
			kdContainer.boundMaxX = p.x1 * WORLD_SCALE;
			kdContainer.boundMaxY = p.y1 * WORLD_SCALE;
			kdContainer.boundMinZ = 0;
			kdContainer.boundMaxZ = MAX_HEIGHT;
			
			
			camera.x = kdContainer.boundMaxX * .5;
			camera.y = kdContainer.boundMaxY * .5;
			camera.z = MAX_HEIGHT + 63400;
			cameraController.updateObjectTransform();
			cameraController.lookAtXYZ(camera.x, camera.y, 0);
			
			var skybox:SkyBox = new SkyBox(99999999);
			skybox.setMaterialToAllFaces( new FillMaterial(0xEEFEFF) );
			rootContainer.addChild(skybox);
			
			
			var floor:Plane = new Plane(kdContainer.boundMaxX, kdContainer.boundMaxY,1,1,false,false,false,null, new FillMaterial(FLOOR_COLOR) );
			floor.clipping = 2;
			rootContainer.addChild(floor);
			floor.x = kdContainer.boundMaxX * .5;
			floor.y = kdContainer.boundMaxY * .5;
			
			rootContainer.addChild(kdContainer);
			
			//ãƒ•ãƒ©ã‚¯ã‚¿ãƒ«ãƒ‡ãƒ¼ã‚¿ä¿æŒç”¨é…åˆ—ã«åˆæœŸå€¤æŒ¿å…¥
			fillRectangleArray = new Array(p);
			addChild(_canvas);
			addEventListener(Event.ENTER_FRAME, onEnterFrame);			
			
		}
		
		private function initA3D():void 
		{
			
			fillA3DBuffers();  // may improve performance for initial run
			
			camera = new Camera3D();
			camera.view = new View(stage.stageWidth, stage.stageHeight);
			stage.addEventListener(Event.RESIZE, onStageResize);
			
			addChild(camera.view);
			
			kdContainer = new KDContainer();
			KD_NODE = getKDNodeClass();
			
			
			cameraController = new SimpleObjectController(stage, camera, 800, 8);
			
			rootContainer = new Object3DContainer();
			rootContainer.addChild(camera);
			
			//camera.addToDebug(Debug.BOUNDS, Box);
			camera.addToDebug(Debug.NODES, KDContainer);
			//camera.addToDebug(Debug.BOUNDS, KDContainer);
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			
		}
		
		private function fillA3DBuffers():void {
			Vertex.collector = Vertex.createList(300);
			Face.collector = createFaceList(100);
			Wrapper.collector = createWrapperList(300);
		}
		
		private function createFaceList(i:int):Face {
			var f:Face = new Face();
			while ( --i > -1) {
				f = f.next = new Face();
			}
			return f;
		}
		
		private function createWrapperList(i:int):Wrapper {
			var f:Wrapper = new Wrapper();
			while ( --i > -1) {
				f = f.next = new Wrapper();
			}
			return f;
		}
		
		private var _doSpawn:Boolean = true;
		
		private function onKeyDown(e:KeyboardEvent):void 
		{
			if (e.keyCode === Keyboard.TAB) {
				camera.debug = !camera.debug;
			}
			if (e.keyCode === Keyboard.BACKSPACE) {
				_doSpawn = !_doSpawn;
			}
		}
		
		private function getKDNodeClass():Class {
			var dummy:KDContainer = new KDContainer();
			dummy.createTree(new <Object3D>[new Box(8,8,8)]);
			return Object(dummy.root).constructor;
		}
		
		private function onStageResize(e:Event):void 
		{
			camera.view.width = stage.stageWidth;
			camera.view.height = stage.stageHeight;
		}
		
		private function setupNode(p:RectanglePiece):* {
			var node:*;
			p.node = node =  new KD_NODE();
			node.boundMinX = p.x0 * WORLD_SCALE;
			node.boundMinY = p.y0 * WORLD_SCALE;
			node.boundMinZ = 0;
			node.boundMaxX = p.x1 * WORLD_SCALE;
			node.boundMaxY = p.y1 * WORLD_SCALE;
			node.boundMaxZ = MAX_HEIGHT;
			return node;
		}
		
		
		
		// todo: optimization and pooling?
		private function createBuilding(p:RectanglePiece, color:uint, fromHeight:Number, fromColor:uint):void
		{
			///*
			
			//node.boundMaxZ = 0;
			//*/
			var node:* = p.node;
			
			var height:Number = 1 + _tint * MAX_HEIGHT;
			var w:Number = (p.x1 - p.x0) * WORLD_SCALE;
			var h:Number = (p.y1 - p.y0) * WORLD_SCALE;
			var building:KDBuilding = new KDBuilding(p.x0 * WORLD_SCALE, p.y0 * WORLD_SCALE, w, h, height, color);
			
			building.height = fromHeight;
			TweenLite.to(building, 1.6, { height:height, ease:Cubic.easeInOut } );
			
			(building.faceList.material as FillMaterial).color = fromColor;
			TweenLite.to(building.faceList.material, .4, { hexColors: {color:color}, ease:Linear.easeNone } );
			
			node.objectList = building;
			node.objectBoundList = building;
		}
		
		
		
		//ãƒ«ãƒ¼ãƒ—
		private function onEnterFrame(e:Event):void 
		{
			var node:*;
			
			if (!_doSpawn) {
				cameraController.update();
				camera.transformId++;
				camera.render();
				return;
			}
			
			
			//ãƒ•ãƒ©ã‚¯ã‚¿ãƒ«å‡¦ç†çµ‚äº†
			if (fillRectangleArray.length < 1) {
				removeEventListener(Event.ENTER_FRAME, onEnterFrame);
				var tx:TextField = new TextField();
				tx.text = 'çµ‚äº†';
				tx.textColor = 0xFFFFFF;
				addChild(tx);
			}else {
				//ãƒ•ãƒ©ã‚¯ã‚¿ãƒ«ãƒ‡ãƒ¼ã‚¿ä¿æŒç”¨é…åˆ—ã‹ã‚‰1ã¤å–ã‚Šå‡ºã™
				var rect:RectanglePiece = fillRectangleArray.shift();
				var cArray:Array = deviationLogic(rect.x0, rect.y0, rect.x1, rect.y1);
				rect.c = cArray[0];
				rect.color = cArray[1];
				
				var halfWidth:Number = (rect.x1 - rect.x0) * .5;
				var halfHeight:Number = (rect.y1 - rect.y0) * .5;
				
				// æŒ‡å®šã—ãŸçŸ©å½¢å†…ã®è¼åº¦ã®æ¨™æº–åå·®å€¤ãŒé–¾å€¤ä»¥ä¸Šãªã‚‰2åˆ†æœ¨ã—ã¦å‡¦ç†ç¶šè¡Œ
				if (rect.c > THRESHOLD && (halfWidth > 2 || halfHeight > 2)) {
					//çŸ©å½¢ã‚’æ›¸ãã‚ˆ
					/*
					_canvas.graphics.lineStyle(0, 0xAAAAAA);
					_canvas.graphics.beginFill(cArray[1]);
					_canvas.graphics.drawRect(rect.x0, rect.y0, (rect.x1 - rect.x0), (rect.y1 - rect.y0));
					*/
					
					node  = rect.node;
					var removeObj:KDBuilding;
					if (rect.parent != null ) {
						if ((removeObj=rect.parent.node.objectList) != null) {
							
							rect.parent.node.objectList = null;
							// todo: cut road along parent splitter.
							
							if (rect.positive) {
								rect.parent.node.positive = node;
								rect.parent.node.negative = rect.sibling.node;
							}
							else {
								rect.parent.node.negative = node;
								rect.parent.node.positive = rect.sibling.node;
							}
							TweenLite.killTweensOf(removeObj);
							createBuilding(rect, rect.color, removeObj.height, rect.parent.color);
							createBuilding(rect.sibling, rect.parent.color, removeObj.height, rect.parent.color);
							
						}
						else {  // fill up remaining branch (either negative or postiive)
							if (rect.positive) {
								rect.parent.node.positive = node;
								removeObj = rect.parent.node.negative.objectList;
							}
							else {
								rect.parent.node.negative = node;
								removeObj = rect.parent.node.positive.objectList;
							}
							createBuilding(rect, rect.color, removeObj.height, rect.parent.color);
						}
					}
					else { // Root node case!
						createBuilding(rect, rect.color, 0, FLOOR_COLOR);
					}
					
					
					//çŸ©å½¢ã‚’2åˆ†å‰²ã—ã¦ãƒ•ãƒ©ã‚¯ã‚¿ãƒ«ãƒ‡ãƒ¼ã‚¿ä¿æŒç”¨é…åˆ—ã«çªã£è¾¼ã‚€
					
					var rect0:RectanglePiece = new RectanglePiece();
					var rect1:RectanglePiece = new RectanglePiece();
					var randomX:Number = Math.floor(Math.random()*(halfWidth-4)+4); 
					var randomY:Number = Math.floor(Math.random()*(halfHeight-4)+4);
					
					
					// Rather hackish pointers here!
					rect0.positive = false;
					rect1.positive = true;
					rect0.sibling = rect1;
					rect1.sibling  = rect0;
					rect0.parent = rect;
					rect1.parent = rect;
					
					if (halfWidth > halfHeight) {
						
						node.axis = 0;
						node.coord = (rect.x0 + randomX) * WORLD_SCALE;
						node.minCoord = node.coord - kdContainer.threshold;
						node.maxCoord = node.coord + kdContainer.threshold;
						
						rect0.x0 = rect.x0;   // negative x
						rect0.y0 = rect.y0;
						rect0.x1 = rect.x0+randomX;
						rect0.y1 = rect.y1;
						fillRectangleArray.push(rect0);
						
						rect.node.negative
						setupNode(rect0);
						
						
						rect1.x0 = rect.x0+randomX;  // postive x
						rect1.y0 = rect.y0;
						rect1.x1 = rect.x1;
						rect1.y1 = rect.y1;
						fillRectangleArray.push(rect1);
						
						
						rect.node.positive;
						setupNode(rect1);
						
						
					}else {
						node.axis = 1;
						node.coord = (rect.y0 + randomY) * WORLD_SCALE;
						node.minCoord = node.coord - kdContainer.threshold;
						node.maxCoord = node.coord + kdContainer.threshold;
						
						rect0.x0 = rect.x0;  // negative y
						rect0.y0 = rect.y0;
						rect0.x1 = rect.x1;
						rect0.y1 = rect.y0+randomY;
						fillRectangleArray.push(rect0);
						
						rect.node.negative;
						setupNode(rect0);
						
						
						rect1.x0 = rect.x0;  //postive y
						rect1.y0 = rect.y0+randomY;
						rect1.x1 = rect.x1;
						rect1.y1 = rect.y1;
						fillRectangleArray.push(rect1);
						
						
						rect.node.positive
						setupNode(rect1);
						
					}
				}
			}
			
			cameraController.update();
			camera.transformId++;
			camera.render();
		}
		/**
		 * æŒ‡å®šã—ãŸçŸ©å½¢é–“ã®è¼åº¦ã®æ¨™æº–åå·®ã‚’æ±‚ã‚ã‚‹
		 * @param    x0    å·¦ä¸Šã®xåº§æ¨™
		 * @param    y0    å·¦ä¸Šã®ï½™åº§æ¨™
		 * @param    x1    å³ä¸‹ã®xåº§æ¨™
		 * @param    y1    å³ä¸‹ã®yåº§æ¨™
		 * @return    æ¨™æº–åå·®å€¤ã¨ã‚«ãƒ©ãƒ¼ã®å¹³å‡
		 */
		private function deviationLogic(x0:Number,y0:Number,x1:Number,y1:Number):Array {
			var rgb:uint = 0;
			var r:uint = 0;
			var g:uint = 0;
			var b:uint = 0;
			var hsb:Array = new Array();
			var bArray:Array = new Array();
			var br:Number = 0;
			var av:Number = 0;
			
			//è¼åº¦ã®å¹³å‡ã‚’è¨ˆç®—
			for (var i:int = x0; i < x1;i++ ) {
				for (var j:int = y0; j < y1; j++ ) {
					rgb = imageData.getPixel(i, j);
					r += (rgb >> 16) & 255;
					g += (rgb >> 8) & 255;
					b += rgb & 255;
					hsb = uintRGBtoHSB(rgb);
					br += hsb[2];
					bArray.push(hsb[2]);
				}
			}
			av = br / bArray.length;
			r = r / bArray.length;
			g = g / bArray.length;
			b = b / bArray.length;
			rgb = (r << 16) | (g << 8) | (b << 0);
			_tint = (255 - ( 0.21 * r + 0.71 * g + 0.07 * b )) * INV_255;
			//æ¨™æº–åå·®ã‚’è¨ˆç®—
			br = 0;
			for (i = 0; i < bArray.length; i++ ) {
				br += (bArray[i] - av) *(bArray[i] - av);
			}
			return [Math.sqrt(br / bArray.length),rgb];
			
		}
		/**
		 * 
		 * @param    rgb    RGBæˆåˆ†ï¼ˆuint)
		 * @return HSBé…åˆ—([0]=hue, [1]=saturation, [2]=brightness)
		 */
		private function uintRGBtoHSB(rgb:uint):Array {
			var r:uint = (rgb >> 16) & 255;
			var g:uint = (rgb >> 8) & 255;
			var b:uint = rgb & 255;
			return RGBtoHSB(r, g, b);
		}
		/** RGBã‹ã‚‰HSBã‚’ã¤ãã‚‹
		 * @param r    è‰²ã®èµ¤è‰²æˆåˆ†(0ï½ž255)
		 * @param g è‰²ã®ç·‘è‰²æˆåˆ†(0ï½ž255)
		 * @param b è‰²ã®é’è‰²æˆåˆ†(0ï½ž255)
		 * @return HSBé…åˆ—([0]=hue, [1]=saturation, [2]=brightness)
		 */
		private function RGBtoHSB(r:int, g:int, b:int):Array {
			var cmax:Number = Math.max(r, g, b);
			var cmin:Number = Math.min(r, g, b);
			var brightness:Number = cmax / 255.0;
			var hue:Number = 0;
			var saturation:Number = (cmax != 0) ? (cmax - cmin) / cmax : 0;
			if (saturation != 0) {
				var redc:Number = (cmax - r) / (cmax - cmin);
				var greenc:Number = (cmax - g) / (cmax - cmin);
				var bluec:Number = (cmax - b) / (cmax - cmin);
				if (r == cmax) {
					hue = bluec - greenc;
				} else if (g == cmax) {
					hue = 2.0 + redc - bluec;
				} else {
					hue = 4.0 + greenc - redc;
				}
				hue = hue / 6.0;
				if (hue < 0) {
					hue = hue + 1.0;
				}
			}
			return [hue, saturation, brightness];
		}
	}    
}
import alternativa.engine3d.core.Camera3D;
import alternativa.engine3d.core.Canvas;
import alternativa.engine3d.core.Face;
import alternativa.engine3d.core.Vertex;
import alternativa.engine3d.core.VG;
import alternativa.engine3d.core.Wrapper;
import alternativa.engine3d.materials.FillMaterial;
import alternativa.engine3d.objects.Mesh;
import alternativa.engine3d.primitives.Box;
import alternativa.engine3d.alternativa3d;
use namespace alternativa3d;

/**
 * ...
 * @author DefaultUser (Tools -> Custom Arguments...)
 */
class RectanglePiece 
{
	public var x0:Number;
	public var y0:Number;
	public var x1:Number;
	public var y1:Number;
	public var c:Number;
	public var node:*;
	public var parent:RectanglePiece;
	public var positive:Boolean;
	public var color:uint;
	public var sibling:RectanglePiece;
	
	public function RectanglePiece() 
	{
		this.x0 = 0;
		this.y0 = 0;
		this.x1 = 0;
		this.x1 = 0;
		this.c = 0;            
	}
	
}

class KDBuilding extends Mesh
{
	// TODD: Can consider recycling of KDBuildings
	
	public function KDBuilding(xPos:Number, yPos:Number, width:Number, length:Number, height:Number, color:uint) 
	{
		clipping = 2;
		sorting = 0;
		
		var v1:Vertex;
		var v2:Vertex;
		var v3:Vertex;
		var v4:Vertex;
		
		var mat:FillMaterial = new FillMaterial(color);
		var v:Vertex;
		var f:Face;
		var w:Wrapper;
		
		// Define top roof vertices
		vertexList = v = Vertex.collector || new Vertex(); v.u = 0; v.v = 0;
		Vertex.collector = v.next;
		v.x = xPos;
		v.y = yPos;
		v.z = height;
		v1 = v;
		
		v.next =  v = v.create(); v.u = 0; v.v = 0;
		v.x = xPos + width;
		v.y = yPos;
		v.z = height;
		v2 = v;
		
		v.next =  v = v.create(); v.u = 0; v.v = 0;
		v.x = xPos + width;
		v.y = yPos + length;
		v.z = height;
		v3 = v;
		
		v.next = v =  v.create(); v.u = 0; v.v = 0;
		v.x = xPos;
		v.y = yPos + length;
		v.z = height;
		v4 = v;
		
		var v5:Vertex;
		var v6:Vertex;
		var v7:Vertex;
		var v8:Vertex;
		
		// Define bottom vertices
		v.next = v = v.create(); v.u = 0; v.v = 0;
		v.x = xPos;
		v.y = yPos;
		v.z = 0;
		v5 = v;
		
		v.next =  v = v.create(); v.u = 0; v.v = 0;
		v.x = xPos + width;
		v.y = yPos;
		v.z = 0;
		v6 = v;
		
		v.next =  v = v.create(); v.u = 0; v.v = 0;
		v.x = xPos + width;
		v.y = yPos + length;
		v.z = 0;
		v7 = v;
		
		v.next = v =  v.create(); v.u = 0; v.v = 0;
		v.x = xPos;
		v.y = yPos + length;
		v.z = 0;
		v8 = v;
		
		// top face
		faceList = f = Face.collector || new Face();
		Face.collector = f.next;
		f.material = mat;
		f.wrapper = w = Wrapper.collector || new Wrapper();
		Wrapper.collector = w.next; 
		w.vertex = v1;
		w.next = w = w.create();
		w.vertex = v2;
		w.next = w = w.create();
		w.vertex = v3;
		w.next = w = w.create();
		w.vertex = v4;
		f.normalX = 0;
		f.normalY = 0;
		f.normalZ = 1;
		f.offset = height;
		
		// South face
		f.next = f = f.create();
		f.material = mat;
		f.wrapper = w = w.create();
		w.vertex = v1;
		w.next = w = w.create();
		w.vertex = v2;
		w.next = w = w.create();
		w.vertex = v6;
		w.next = w = w.create();
		w.vertex = v5;
		f.normalX = 0;
		f.normalY = -1;
		f.normalZ = 0;
		f.offset = -yPos;
		
		// East Face
		f.next = f = f.create();
		f.material = mat;
		f.wrapper = w = w.create();
		w.vertex = v2;
		w.next = w = w.create();
		w.vertex = v3;
		w.next = w = w.create();
		w.vertex = v7;
		w.next = w = w.create();
		w.vertex = v6;
		f.normalX = 1;
		f.normalY = 0;
		f.normalZ = 0;
		f.offset = xPos + width;
		
		
		// North Face
		f.next = f = f.create();
		f.material = mat;
		f.wrapper = w = w.create();
		w.vertex = v3;
		w.next = w = w.create();
		w.vertex = v4;
		w.next = w = w.create();
		w.vertex = v8;
		w.next = w = w.create();
		w.vertex = v7;
		f.normalX = 0;
		f.normalY = 1;
		f.normalZ = 0;
		f.offset = yPos + length;
		
		// West Face
		f.next = f = f.create();
		f.material = mat;
		f.wrapper = w = w.create();
		w.vertex = v4;
		w.next = w = w.create();
		w.vertex = v1;
		w.next = w = w.create();
		w.vertex = v5;
		w.next = w = w.create();
		w.vertex = v8;
		f.normalX = -1;
		f.normalY = 0;
		f.normalZ = 0;
		f.offset = -xPos;
		
		// ^^^ note vertex normals not coded in!
		
		
		// calculate bounds
		boundMinX = xPos;
		boundMinX = yPos;
		boundMinZ = 0;
		boundMaxX = xPos + width;
		boundMaxY = yPos + length;
		boundMaxZ = height;
		
		
		
	}
	
	// Boiler-plate mesh draw implementation to prevent errors with camera.debug mode due to
	// private classes.
	override alternativa3d function draw(camera:Camera3D, parentCanvas:Canvas):void {
		
		calculateInverseMatrix();
		// either transformId++; or if camera.transformId used as an incrementing timestamp
		transformId = camera.transformId;  
		var f:Face = prepareFaces(camera);
		if (f == null) return;
		if (culling > 0) {
			f = camera.clip(f, culling);
			if (f == null) return;
		}
		drawFaces(camera, parentCanvas.getChildCanvas(true, false, this, 1, blendMode, colorTransform, filters), f);
		
	}
	
	override alternativa3d function getVG(camera:Camera3D):VG {
		
		calculateInverseMatrix();
		// either transformId++; or if camera.transformId used as an incrementing timestamp
		transformId = camera.transformId;
		var f:Face = prepareFaces(camera);
		if (f == null) return null;
		if (culling > 0) {
			camera.clip(f, culling);
			if (f == null) return null;
		}
		return VG.create(this, f, sorting, 0, false);
		
	}
	
	
	
	public function get height():Number { return vertexList.z; }
	
	// TODO: Adjust height of related KD nodes as well once chars are put in
	public function set height(value:Number):void 
	{
		var v:Vertex = vertexList;
		v.z = value; v = v.next;
		v.z = value; v = v.next;
		v.z = value; v = v.next;
		v.z = value;
		faceList.offset = value;
		boundMaxZ = value;
	}
	
	
	
}
