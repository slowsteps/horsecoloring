﻿package  {		import flash.display.MovieClip;	import flash.geom.ColorTransform;	import flash.events.MouseEvent;	import flash.events.Event;	import fl.transitions.Tween; 	import fl.transitions.easing.*;	import flash.events.TouchEvent;	import flash.ui.Multitouch;	import flash.ui.MultitouchInputMode;	import com.greensock.TweenMax;	import com.greensock.*;	import com.greensock.easing.*;			public class Pattern extends MovieClip {						public var mymain: Main;	public var patternNum: int;	public var patternName;	public var isBrush:Boolean;	public var origWidth:Number	public var origHeight:Number	public var origScaleX:Number	public var origScaleY:Number	private var stamp:MovieClip	private var pulsetween:TweenMax				public function Pattern(inmain) {						this.cacheAsBitmap = true;			mymain = inmain		}						public function setPatternNumber(inNum:int) {			patternNum = inNum						//Pattern itself has no visuals, stamp is added here:						var stampclip = mymain.patterns[patternNum]			//bounding box scale			var overshootx = stampclip.width - this.width			var overshooty = stampclip.height - this.height			var scalefactor			if (overshootx > overshooty) {				scalefactor = this.width/stampclip.width			}			else {				scalefactor = this.height/stampclip.height			}						stamp = this.addChild(mymain.patterns[patternNum]) as MovieClip			stamp.width  = stamp.width * scalefactor			stamp.height = stamp.height * scalefactor									origWidth = stamp.width			origHeight = stamp.height			origScaleX = stamp.scaleX			origScaleY = stamp.scaleY									var hitzone = new Hitzone()			hitzone.width = 1.2*this.width			hitzone.height = 1.2*this.height			hitzone.x = this.x - hitzone.width/2			hitzone.y = this.y - hitzone.height/2			hitzone.alpha = 0			mymain.addChild(hitzone)			hitzone.addEventListener(MouseEvent.ROLL_OVER,onDown)			hitzone.addEventListener(TouchEvent.TOUCH_BEGIN,onDown)						//set stamp to back so that hitzone is in front			mymain.setChildIndex(this,0);											}					private function onDown(e:Event) {						mymain.setPattern(this,patternNum)			mymain.onSwatchClick(this)						if (isBrush) mymain.drawMode = "brush"; 			else mymain.drawMode = "pattern"; 						TweenMax.to(this, 0.3, {dropShadowFilter:{color:0x000033, alpha:0.8, blurX:10, blurY:10, distance:8}});			pulsetween = TweenMax.to(stamp,0.3,{scaleX:1.2,scaleY:1.2,yoyo:true,repeat:-1,overwrite:false})		}				public function releaseFocus() {								TweenMax.to(this, 0.2, {dropShadowFilter:{color:0x000033, alpha:0, blurX:0, blurY:0, distance:0}});			pulsetween.kill()			TweenMax.to(stamp,0.5,{scaleX:origScaleX,scaleY:origScaleY,overwrite:false})		}							}	}