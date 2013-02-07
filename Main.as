﻿package  {	import flash.display.MovieClip;	import flash.display.Bitmap;	import flash.display.BitmapData;	import flash.display.BlendMode;	import flash.events.MouseEvent;	import flash.events.TouchEvent;	import flash.ui.Multitouch;	import flash.ui.MultitouchInputMode;		import flash.events.Event;	import flash.geom.ColorTransform;	import flash.geom.Rectangle;	import flash.geom.Point;	import flash.net.URLRequest;	import flash.net.URLLoader;	import flash.net.navigateToURL;	import flash.geom.Matrix;	import fl.transitions.Tween; 	import fl.transitions.easing.*; 	import flash.filters.BitmapFilter; 	import fl.transitions.TweenEvent; 	import flash.utils.Timer; 	import flash.events.TimerEvent;	import flash.events.Event;	import flash.ui.Mouse;	import flashx.textLayout.formats.BackgroundColor;			public class Main extends flash.display.MovieClip {		var bmdataColors:BitmapData; // floodfill color layer		var bmdataOutlines:BitmapData; //outline layer incl. new user drawn outlines.		var bmdataOriginalOutlines:BitmapData; //outline layer incl. new user drawn outlines.		var bmdataPattern:BitmapData; //stamps layer (flowers etc)		var bmdataBackdrop:BitmapData; //huh?		 						var AchievementCount:int=0;		var savedAchievements:Array;		var colSwatch:MovieClip;		var clickLogo:MovieClip;		var resetButton:MovieClip;		var menuButton:MovieClip;		var mainMenu:MovieClip;		var AchievementMessage:Message;		var numColSwatchesSelected:int=0;		var colors:Array;		var colorNames:Array;		var curcolor:uint=0xFFFF8C00;		var curColorName:String		var curPatternNum:int=0;		var curPattern;		var savePattern;		var lastClicked;		var patterns:Array;		var padding = 15;		var canvas;		var drawMode:String = "color";		var clicks:int;		var customCursor:MovieClip;		var sprayTimer:Timer;		var lastX:Number;		var lastY:Number;		//resolution independent helpers		var gameWidth:Number = 1024;		var gameHeight:Number = 768;		var spacing:Number		var stagePadding:Number = 20;		var clickX:Number;		var clickY:Number;		public var gameState:String = "coloring"		public var achievementManager:AchievementManager		public function Main() {											savedAchievements = new Array();			canvas = new MovieClip();												createColors()			createPatterns()						selectDrawing()						createBackground()							//LAYER 1						addChild(canvas);			canvas.addChild(new Bitmap(bmdataColors));			canvas.x = gameWidth/2 - (bmdataColors.width/2)						//LAYER 2			bmdataBackdrop = new BitmapData(gameWidth,gameHeight,true,0x00000000)			var backdropbm = new Bitmap(bmdataBackdrop)			var backdropclip = this.addChild(backdropbm);									//resetbutton			createUtilities()			createAchievementManager()						//message fly-in			AchievementMessage = new Message();			addChild(AchievementMessage);			AchievementMessage.x=-1000;								if (Multitouch.supportsTouchEvents) trace("touch device");			else trace("mouse device");									Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;			//events						//Touch Events			this.canvas.addEventListener(TouchEvent.TOUCH_BEGIN,onClickDown)			this.canvas.addEventListener(TouchEvent.TOUCH_END,onClickUp)			this.canvas.addEventListener(TouchEvent.TOUCH_MOVE,onMove);			//debug												this.clickLogo.addEventListener(MouseEvent.MOUSE_DOWN,onLogoClick);	 			//airbrush speed			sprayTimer = new flash.utils.Timer(150,0);			sprayTimer.addEventListener(TimerEvent.TIMER,onSpray);						//animation effect timer			var animationTimer = new flash.utils.Timer(30,0);			//animationTimer.addEventListener(TimerEvent.TIMER,onAnimateFX)			//animationTimer.start()		  			//daily achievement			var date:Date = new Date();			var weekdays = new Array("sunday","monday","tuesday","wednesday","thursday","friday","saturday");			showAchievementMessage(weekdays[date.day].toString() + " player");					}				//var frametick:Number = 0				var bmdataFxBuffer:BitmapData = new BitmapData(gameWidth,gameHeight)				function onAnimateFX(e:Event) {						var mat:Matrix=new Matrix();			var scalefactor = 1.01			//mat.scale(scalefactor,scalefactor);						//mat.rotate(-40*0.017 + 80*Math.random()*0.017);			mat.translate(0,0);			var CT = new ColorTransform(1,1,1,0.98,0,0,0,0.0)			bmdataFxBuffer.copyPixels(this.bmdataBackdrop,new Rectangle(0,0,gameWidth,gameHeight),new Point(0,0),null,null,false)			bmdataBackdrop.fillRect(new Rectangle(0,0,gameWidth,gameHeight),0x00000000);			this.bmdataBackdrop.draw(this.bmdataFxBuffer,mat,CT,null,null,false)								}		function onMove(e:TouchEvent) {			clickX = e.localX;			clickY = e.localY;		}		function onSpray(e) {			//called by sprayTimer, to start regular spray of pattern stamps						this.drawPattern(clickX,clickY);			this.redrawSavedDrawing();		}		function onClickUp(e) {						//stop straying patterns			sprayTimer.stop();			//stop drawing with the brush			this.canvas.removeEventListener(TouchEvent.TOUCH_MOVE,onDrawWithBrush)		}		function redrawSavedDrawing() {			bmdataColors.copyPixels(bmdataOutlines,new Rectangle(0,0,bmdataColors.width,bmdataColors.height),new Point(0,0),null,null,true);		}		function redrawOriginalDrawing() {			bmdataColors.copyPixels(bmdataOriginalOutlines,new Rectangle(0,0,bmdataColors.width,bmdataColors.height),new Point(0,0),null,null,true);			bmdataOutlines.copyPixels(bmdataOriginalOutlines,new Rectangle(0,0,bmdataColors.width,bmdataColors.height),new Point(0,0),null,null,true);		}				//function onDrawWithBrush(e:TouchEvent) {  UNDO		function onDrawWithBrush(e:TouchEvent) {						//interpolate between mousemove events to prevent gaps in lines			var numsteps = 10			var stepX = (e.localX - lastX)/numsteps;			var stepY = (e.localY - lastY)/numsteps;						//clear once			for (var i=0;i<numsteps;i++) {				this.drawPattern( (lastX + i*stepX), (lastY + i*stepY));			}			this.redrawSavedDrawing();						lastX = e.localX;			lastY = e.localY;								}				//achievement messafge		//TODO		//fireEvent("blue",1), 1 per second: map achievement rules on all collected events		//check against saved events via array of functions (rules), queue new achievements for display animation		//ex. completist check blue, red etc exists., 		//if achievement unlocked flag achievement rule/function as done so the loop will skip it.		public function showAchievementMessage(inMsg:String) {						if (savedAchievements.indexOf(inMsg)==-1) {				savedAchievements.push(inMsg);				AchievementMessage.y=100;				if (savedAchievements.length == 1) AchievementMessage.msg.text = "First achievement unlocked! \n" + "\"" + inMsg +"\"";				else AchievementMessage.msg.text = savedAchievements.length + " Achievements unlocked! \n" + "\"" + inMsg +"\"";				var myTween1:Tween = new Tween(AchievementMessage, "x", Regular.easeInOut, gameWidth+AchievementMessage.width, (gameWidth-AchievementMessage.width), 0.3, true);				var removeTimer:Timer = new flash.utils.Timer(1500,1);				removeTimer.addEventListener(TimerEvent.TIMER_COMPLETE,onAchievementMotionFinished);				removeTimer.start();			}			else trace("achievement already saved " + savedAchievements)		}								//A color swatch is clicked		public function setColSwatch(colswatch: Swatch) {			curcolor = colswatch.col;			this.curColorName = colswatch.colname;		}				//A stamp ("pattern") swatch is clicked		public function setPattern(inPattern:Pattern,inNum:int) {									curPatternNum = inNum			//if (savePattern != null) savePattern.releaseFocus()			this.savePattern = inPattern										}				public function onSwatchClick(swatch) {						if (lastClicked != null) lastClicked.releaseFocus()			lastClicked = swatch					}				private function onAchievementMotionFinished(e:Event) {			var myTween1:Tween = new Tween(AchievementMessage, "x", Regular.easeIn, AchievementMessage.x, gameWidth+AchievementMessage.width, 0.5, true);		}				public function animBounce(inclip:MovieClip,origScaleX:Number,origScaleY:Number) {			var myTween1:Tween = new Tween(inclip, "scaleX", Elastic.easeOut, 1.5*origScaleX, origScaleX, 2, true);			var myTween2:Tween = new Tween(inclip, "scaleY", Elastic.easeOut, 1.5*origScaleY, origScaleY, 2, true);		}		public function animBounceBack(inclip:MovieClip,origScaleX:Number,origScaleY:Number) {						var myTween1:Tween = new Tween(inclip, "scaleX", Regular.easeInOut, inclip.scaleX, origScaleX, 1, true);			var myTween2:Tween = new Tween(inclip, "scaleY", Regular.easeIn, inclip.scaleY, origScaleY, 1, true);		}		public function animFlyin(inclip) {			var duration:Number = 1;			new Tween(inclip, "x", Regular.easeInOut, -inclip.width, inclip.x, duration, true);					}		private function drawPattern(inX,inY) {			//the position on the canvas where the pattern need to be drawn			var posx = inX - (bmdataPattern.width/2);			var posy = inY - (bmdataPattern.height/2);						curPattern = patterns[curPatternNum];					//clear			if (curPattern.isBrush) {				//no need to clear, just draw the same brushtip over and over again			}			else {				//patterns are rotated etc, so needs to be cleared for next drawcycle				bmdataPattern.fillRect(new Rectangle(0,0,bmdataPattern.width,bmdataPattern.height),0x00000000);			}			//draw						//some random effects to make each stamp look a bit different, keep it clean for brushes						var mat:Matrix=new Matrix();			var scalefactor = 0.4 + 0.6*Math.random()			//scale the stamp patterns, not the brush			if (!curPattern.isBrush) mat.scale(scalefactor,scalefactor);			if (!curPattern.isBrush) mat.rotate(-40*0.017 + 80*Math.random()*0.017);			mat.translate(bmdataPattern.width/2,bmdataPattern.height/2);						//intermediate draw pass for transformation			//brush icon is not used for drawing, it's child "stamp" is.			if (curPattern.isBrush) {				bmdataPattern.draw(curPattern.stamp,mat)			}			else {				bmdataPattern.draw(curPattern,mat)							}						if (curPattern.isBrush) {				//only copy the	small brushtip. no need to clear because brush is not scaled or rotated							var centerx = (bmdataPattern.width/2) - (curPattern.width/2)				var centery = (bmdataPattern.height/2) - (curPattern.height/2)				bmdataOutlines.copyPixels(bmdataPattern,new Rectangle(centerx,centery,curPattern.width,curPattern.height),new Point(posx+centerx,posy+centery),null,null,true);											}							else {				//draw color fills in backdrop layer				bmdataBackdrop.copyPixels(bmdataPattern,new Rectangle(0,0,bmdataColors.width,bmdataColors.height),new Point(posx,posy),null,null,true);							}			//			//					}		private function onClickDown(e:TouchEvent) {									//TODO with mouseX and mouseY check where clicked in the drawing to create achievements			//like blue eyed horse, Inkback nights, dark horse etc, sunglasses, sleepy horse.			//could provide list of achievements only if there are a little cryptic						clicks++									if (clicks == 3) showAchievementMessage("Brush cleaning assistant");			if (clicks == 10) showAchievementMessage("Apprentice sketcher");			if (clicks == 50) showAchievementMessage("Junior painter");			if (clicks == 100) showAchievementMessage("Awesome artist");			if (clicks == 250) showAchievementMessage("Paint princess");			if (clicks == 500) showAchievementMessage("Master painter");			if (clicks == 1000) showAchievementMessage("Brush goddess");						if (drawMode == "color") {				bmdataColors.floodFill(e.localX,e.localY,curcolor);				achievementManager.track({type:"colorpaint",colorname:curColorName,x:e.localX,y:e.localY})			}			else if (drawMode == "pattern") {				//draw once straight away and start spraying if mouse stays down												drawPattern(e.localX,e.localY);					sprayTimer.start();			}			else if (drawMode == "brush") {				//keep drawing line until mouse up.				//clear once								bmdataPattern.fillRect(new Rectangle(0,0,bmdataPattern.width,bmdataPattern.height),0x00000000);				lastX=e.localX				lastY=e.localY				drawPattern(e.localX,e.localY);								this.canvas.addEventListener(TouchEvent.TOUCH_MOVE,onDrawWithBrush);							}			else trace("unknown drawmode: " + drawMode)			//redraw outlines			this.redrawSavedDrawing();		}		private function onLogoClick(e:Event) {						var url:URLRequest = new URLRequest("http://www.sohorses.com");			navigateToURL(url,"_blank");								}		private function createColors() {			colors = new Array();			colorNames = new Array();			colors.push(0xFFFF0000);			colorNames.push("red");			colors.push(0xFF0DD124);			colorNames.push("green");			colors.push(0xFF0000FF);			colorNames.push("blue");			colors.push(0xFFB88A00);			colorNames.push("light brown");			colors.push(0xFFFF33CC);			colorNames.push("pink");			colors.push(0xFFFF8C00);			colorNames.push("orange");			colors.push(0xFF8C23BF);			colorNames.push("purple");			colors.push(0xFFFFFF00);			colorNames.push("yellow");			colors.push(0xFF6FAAFD);			colorNames.push("light blue");			colors.push(0xFF5F382A);			colorNames.push("dark brown");			colors.push(0xFFFFF0B6);			colorNames.push("blond");			colors.push(0xFFFFFFFF);			colorNames.push("white");			colors.push(0xFF000000);			colorNames.push("black");			spacing = (gameWidth / (colors.length + 1))						//line up the color swatches			for (var i=0;i<colors.length;i++) {				colSwatch = new Swatch();				addChild(colSwatch);				//colSwatch.x = padding + colSwatch.width/2 + (colSwatch.width + padding)*i; 				colSwatch.x = spacing + (spacing*i)								colSwatch.y = gameHeight - 120;				colSwatch.mymain = this;				colSwatch.setColor(colors[i],i,colorNames[i]);							}		}				private function createPatterns() {						patterns = new Array();			patterns.push(new Grass());			patterns.push(new Flower());			patterns.push(new Star());			patterns.push(new Heart());			patterns.push(new Butterfly());			patterns.push(new Horseshoe());			patterns.push(new Brush(0));												for (var i:int=0;i<patterns.length;i++) {								patterns[i].cacheAsBitmap = true;								var patSwatch:Pattern = new Pattern(this);												if (patterns[i].isBrush) 	patSwatch.isBrush = true				else 						patSwatch.isBrush = false								//positioning and init				patSwatch.y = gameHeight - 0.5*patSwatch.height - stagePadding;				patSwatch.x = spacing + (spacing*i);								this.addChild(patSwatch);				patSwatch.setPatternNumber(i);			}					}				public function selectDrawing(drawingClip:MovieClip=null) {						if (drawingClip == null) {				trace("drawingClip not specified - displaying default drawing")				drawingClip = new Horsedrawing()			}						//if (drawingNum == 0 ) drawingClip = new Horsedrawing();			//if (drawingNum == 1 ) drawingClip = new Cardrawing();			this.canvas.removeEventListener(TouchEvent.TOUCH_BEGIN,onClickDown)			this.canvas.removeEventListener(TouchEvent.TOUCH_END,onClickUp)			this.canvas.removeEventListener(TouchEvent.TOUCH_MOVE,onMove)						createBitmaps(drawingClip)			this.canvas.addEventListener(TouchEvent.TOUCH_BEGIN,onClickDown)			this.canvas.addEventListener(TouchEvent.TOUCH_END,onClickUp)			this.canvas.addEventListener(TouchEvent.TOUCH_MOVE,onMove);		}						public function createBitmaps(inDrawing:MovieClip) {												//create at startup, clear for consequtive drawings)						if (bmdataColors == null) {								bmdataColors = new BitmapData(gameWidth,gameHeight - 168,true,0x00000000)				bmdataOutlines = new BitmapData(gameWidth,gameHeight - 168,true,0x00000000)				bmdataOriginalOutlines = new BitmapData(gameWidth,gameHeight - 168,true,0x00000000)				bmdataBackdrop = new BitmapData(gameWidth,gameHeight - 168,true,0x00000000)			}			else {						var clearRect:Rectangle = new Rectangle(0,0,gameWidth,gameHeight)				bmdataColors.fillRect(clearRect,0x00000000)				bmdataOutlines.fillRect(clearRect,0x00000000)				bmdataOriginalOutlines.fillRect(clearRect,0x00000000)				bmdataBackdrop.fillRect(clearRect,0x00000000)			}									//load the lineart into the bitmaps			bmdataColors.drawWithQuality(inDrawing,null,null,null,null,false,"low")			bmdataOutlines.drawWithQuality(inDrawing,null,null,null,null,false,"low")			bmdataOriginalOutlines.drawWithQuality(inDrawing,null,null,null,null,false,"low")						//temp buffer for randomizing the rotation of the stamps and the brush			bmdataPattern = new BitmapData(150,150,true,0x00000000);					}						private function createUtilities() {						resetButton = new ResetButton()			resetButton.x = gameWidth - 0.5*resetButton.width - stagePadding			resetButton.y = 0.5*resetButton.height + stagePadding			this.addChild(resetButton);			resetButton.addEventListener(TouchEvent.TOUCH_BEGIN,resetDrawing)			menuButton = new MenuButton()			menuButton.x = 0.5*menuButton.width + stagePadding			menuButton.y = 0.5*menuButton.height + stagePadding			this.addChild(menuButton);			menuButton.addEventListener(TouchEvent.TOUCH_BEGIN,gotoMenu)			menuButton.addEventListener(MouseEvent.MOUSE_DOWN,gotoMenu)			clickLogo = new soHorsesLogo()			clickLogo.x = gameWidth - clickLogo.width - stagePadding			clickLogo.y = gameHeight - clickLogo.height - stagePadding			this.addChild(clickLogo)			mainMenu = new Mainmenu(this)			this.addChild(mainMenu)			mainMenu.cacheAsBitmap = true					}				private function createAchievementManager() {			achievementManager = new AchievementManager(this)		}				private function createBackground() {			var background = this.addChild(new Background())			this.setChildIndex(background,0)		}				private function gotoMenu(e:Event) {						mainMenu.show()								}						private function resetDrawing(e:Event) {			animBounce(resetButton,resetButton.scaleX,resetButton.scaleY)			bmdataColors.fillRect(new Rectangle(0,0,gameWidth,gameHeight),0x00000000)			bmdataOutlines.fillRect(new Rectangle(0,0,gameWidth,gameHeight),0x00000000)			bmdataPattern.fillRect(new Rectangle(0,0,gameWidth,gameHeight),0x00000000)			bmdataBackdrop.fillRect(new Rectangle(0,0,gameWidth,gameHeight),0x00000000)			redrawOriginalDrawing();						}	}	}