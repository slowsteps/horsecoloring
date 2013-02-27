﻿package  {		import flash.display.MovieClip;	import flash.geom.ColorTransform;	import flash.events.MouseEvent;	import flash.events.Event;	import fl.transitions.Tween; 	import fl.transitions.easing.*;	import flash.events.TouchEvent;	import flash.ui.Multitouch;	import flash.ui.MultitouchInputMode;	import com.greensock.TweenMax;	import com.greensock.*;	import com.greensock.easing.*;			public class Swatch extends MovieClip {							public var col:uint;	public var colnum:int;	public var colname:String;	public var mymain: Main;	public var chosen:int=0;	public var origX:Number	public var origY:Number	public var origWidth:Number	public var origHeight:Number	public var origScaleX:Number	public var origScaleY:Number	private var pulsetween:TweenMax						public function Swatch() {			//this.cacheAsBitmapMatrix = this.transform.concatenatedMatrix;			this.cacheAsBitmap = true;		}						public function setColor(incol,incolnum,incolname) {			col = incol;			colnum = incolnum;			colname = incolname;			var CT:ColorTransform = new ColorTransform();			CT.color = col;			this.fill.transform.colorTransform = CT;			origX = x;			origY = y;			origWidth = width			origHeight = height			origScaleX = scaleX			origScaleY = scaleY						var hitzone = new Hitzone()			hitzone.width = 1.2*this.width			hitzone.height = 1.2*this.height			hitzone.x = this.x - hitzone.width/2			hitzone.y = this.y - hitzone.height/2			hitzone.alpha = 0			mymain.addChild(hitzone)			hitzone.addEventListener(MouseEvent.ROLL_OVER,onDown)						hitzone.addEventListener(TouchEvent.TOUCH_BEGIN,onDown)			//set stamp to back so that hitzone is in front			mymain.setChildIndex(this,0)								}					private function onDown(e:Event) {						chosen++;						mymain.setColSwatch(this);			mymain.onSwatchClick(this)						//TweenLite.to(this, 0.3, {y:y-10, ease:Elastic.easeOut});			//TweenMax.to(this, 0.3, {dropShadowFilter:{color:0x000033, alpha:0.6, blurX:10, blurY:10, distance:8}});						TweenMax.to(this, 0.3, {dropShadowFilter:{color:0x000033, alpha:0.8, blurX:10, blurY:10, distance:8}});			pulsetween = TweenMax.to(this,0.3,{scaleX:1.2,scaleY:1.2,yoyo:true,repeat:-1,overwrite:false})						mymain.drawMode = "color"; 		}						public function releaseFocus() {						//TweenLite.to(this, 0.2, {y:origY});			//TweenMax.to(this, 0.2, {dropShadowFilter:{color:0x000033, alpha:0, blurX:0, blurY:0, distance:0}});									TweenMax.to(this, 0.2, {dropShadowFilter:{color:0x000033, alpha:0, blurX:0, blurY:0, distance:0}});			pulsetween.kill()			TweenMax.to(this,0.5,{scaleX:origScaleX,scaleY:origScaleY,overwrite:false})					}							}	}