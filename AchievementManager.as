﻿package  {				import flash.net.SharedObject;	import flash.display.MovieClip;	import com.greensock.TweenMax;	import com.greensock.*;	import com.greensock.easing.*;	import flash.utils.Timer; 	import flash.events.TimerEvent;	import flash.events.Event;	public class AchievementManager {		private var mymain:Main		private var achievements:Array		private var metrics:Array		public var cookie:SharedObject; 		private var msg:MovieClip		public var numAchievements:int=0		private var stack:Array		private var updateTimer:Timer						public function AchievementManager(inmain) {			mymain = inmain			createMessage()			loadData()			updateTimer = new flash.utils.Timer(500,0);			updateTimer.addEventListener(TimerEvent.TIMER,onUpdate)			updateTimer.start()		}		private function createMessage() {			msg = new Message() as MovieClip			mymain.addChild(msg)			msg.x = mymain.gameWidth / 2 - msg.width/2			msg.y = -msg.height					}								private function showMessage() {			var achievement = getNextAchievement()			if (achievement) {				updateTimer.stop()				msg.textfield.text = achievement // flyin				var timeline:TimelineLite = new TimelineLite();				timeline.append( new TweenLite(msg, 1, {y:mymain.padding + 210, ease:Elastic.easeOut}) );				timeline.append( new TweenLite(mymain.credit, 0.1, {y: "-20", ease:Elastic.easeOut }) );				timeline.append( new TweenLite(mymain.credit, 1, {y: "20" , ease:Bounce.easeOut,onComplete:updateCredits }) );				timeline.append( new TweenLite(msg, 1, {y:-msg.height - 50, ease:Back.easeOut, delay:0,onComplete:showMessage}) );								}			else {				updateTimer.start()			}					}				private function updateCredits() {			mymain.creditText.textfield.text = this.getAchievementsList().count		}		private function addToStack(achievementTitle:String) {			stack.push(achievementTitle)		}				private function getNextAchievement() {			if (stack.length>0) return stack.shift()						else return false		}		private function onUpdate(e:Event) {			showMessage()		}		private function loadData() {			cookie = SharedObject.getLocal("achievementManager");			cookie.clear();			trace(cookie,cookie.size,cookie.data.achievements)						if (cookie.data.achievements == null) achievements = new Array()			else (achievements = cookie.data.achievements)						if (cookie.data.metrics == null) metrics = new Array()			else (metrics = cookie.data.metrics)						stack = new Array()								}		//display a full list of unlocked achievements		public function getAchievementsList() : Object {			var achievementlist:String = ""			var count:Number=0			for (var key:Object in achievements) {				achievementlist = achievementlist + "\n - " + key				count++			}							return ({count:count,list:achievementlist})							}		//deal with generated events		public function track(obj) {			//trace("tracking",obj.type)			//color painted			if (obj.type == "colorpaint") {				this.incrementMetric("colorpaints")								this.incrementMetric(obj.colorname)										}			//pattern painted			if (obj.type == "patternpaint") {				this.incrementMetric("patternpaints")								this.incrementMetric(obj.patternname)										}			//colors of the objects (e.g. sky)			if (obj.type == "objectcolors") {				checkForColorCombi(obj)			}			//something with time and date									//store metrics			cookie.data.metrics = metrics			//find out if any new achievements have been unlocked			checkForAchievements()					}				private function checkForColorCombi(obj) {			//available objects: sky, ground,tail,manes,tuft,body			//simple			if (obj.colors.sky == "blue") saveAchievement("mr blue sky") 			if (obj.colors.sky == "black") saveAchievement("horse at night") 			if (obj.colors.sky == "red") saveAchievement("red sky") 						//combi of two			var c = obj.colors			if (c.sky == "black" && c.ground == "white") saveAchievement("polar night") 			if (c.sky == "black" && c.ground == "white") saveAchievement("a nice day on the northpole") 			if (c.sky == "light blue" && c.ground == "blond") saveAchievement("desert horse") 			if (c.sky == "black" && c.ground == "blond") saveAchievement("desert night horse") 			if (c.sky == "light blue" && c.ground == "green") saveAchievement("a nice day in the field") 			if (c.sky == "black" && c.ground == "green") saveAchievement("the field at night") 			if (c.ground == "black") saveAchievement("motorway horse") 						if (c.body == "black" && c.tail == "black" && c.tuft == "black" && c.manes == "black" && c.backleg == "black") saveAchievement("the goth") 			if (c.body == "pink" && c.tail == "pink" && c.tuft == "pink" && c.manes == "pink" && c.backleg == "pink") saveAchievement("the girl") 			if (c.body == "pink") saveAchievement("girly horse")			if (c.body == "brown") saveAchievement("poo colored horse")			if (c.body == "blue") saveAchievement("horse holding breath")			if (c.body == "white") saveAchievement("the white stallion")			if (c.body == "black") saveAchievement("black beauty")											}						//achievement rules		private function checkForAchievements() {			//total colors painted			if (metrics["colorpaints"] == 1) saveAchievement("first!") 			if (metrics["colorpaints"] == 5) saveAchievement("5 clicks") 			if (metrics["colorpaints"] == 10) saveAchievement("10 clicks") 			if (metrics["colorpaints"] == 25) saveAchievement("25 clicks - getting into it?") 			if (metrics["colorpaints"] == 50) saveAchievement("50 clicks") 			if (metrics["colorpaints"] == 100) saveAchievement("100 clicks") 			if (metrics["colorpaints"] == 150) saveAchievement("150 clicks") 			if (metrics["colorpaints"] == 200) saveAchievement("200 clicks") 			if (metrics["colorpaints"] == 300) saveAchievement("300 clicks") 			if (metrics["colorpaints"] == 500) saveAchievement("500 clicks - junior painter") 			if (metrics["colorpaints"] == 750) saveAchievement("750 clicks") 			if (metrics["colorpaints"] == 1000) saveAchievement("1000 clicks - master painter") 			//individual colors painted			if (metrics["red"] == 1) saveAchievement("red, the color of love") 			if (metrics["blue"] == 1) saveAchievement("blue, the man color") 			if (metrics["brown"] == 1) saveAchievement("brown, the color of mud") 			if (metrics["pink"] == 1) saveAchievement("pink, the girly choice") 			if (metrics["orange"] == 1) saveAchievement("orange, the healthy color") 			if (metrics["black"] == 1) saveAchievement("black, always stylish") 			if (metrics["white"] == 1) saveAchievement("white, the non color") 			if (metrics["blond"] == 1) saveAchievement("blond - you tell me") 			if (metrics["purple"] == 1) saveAchievement("purple, if you like it") 			if (metrics["green"] == 1) saveAchievement("green, the eco-color") 			//next up			//individual colors painted			if (metrics["red"] == 50) saveAchievement("red yeah") 			if (metrics["blue"] == 50) saveAchievement("you like blue") 			if (metrics["brown"] == 50) saveAchievement("you like brown") 			if (metrics["pink"] == 50) saveAchievement("you like pink") 			if (metrics["orange"] == 50) saveAchievement("you like orange") 			if (metrics["brown"] == 50) saveAchievement("you like brown") 			if (metrics["black"] == 50) saveAchievement("you like black") 			if (metrics["white"] == 50) saveAchievement("you like white") 			if (metrics["blond"] == 50) saveAchievement("you like blond") 			if (metrics["purple"] == 50) saveAchievement("you like purple") 			if (metrics["green"] == 50) saveAchievement("you like green") 						//stamps placed			if (metrics["flower"] == 10) saveAchievement("10 flowers") 			if (metrics["heart"] == 10) saveAchievement("10 hearts") 			if (metrics["star"] == 10) saveAchievement("10 stars") 			if (metrics["paws"] == 10) saveAchievement("1o paws") 			if (metrics["butterfly"] == 10) saveAchievement("10 butterflies") 			if (metrics["brush"] == 10) saveAchievement("10 butterflies") 			//more stamps			if (metrics["flower"] == 50) saveAchievement("10 flowers") 			if (metrics["heart"] == 50) saveAchievement("10 hearts") 			if (metrics["star"] == 50) saveAchievement("10 stars") 			if (metrics["paws"] == 50) saveAchievement("1o paws") 			if (metrics["butterfly"] == 50) saveAchievement("10 butterflies") 			if (metrics["brush"] == 50) saveAchievement("10 butterflies") 					}						//check for new achievements		private function saveAchievement(achievementTitle:String) {						if (achievements[achievementTitle] == null)	{				achievements[achievementTitle] = 1								//store				cookie.data.achievements = achievements				cookie.flush()								addToStack(achievementTitle)							}					}				//visual reward				//utility singleton for metrics		private function incrementMetric(metric) {			if (metric == undefined) trace("Undefined metric")			if (metrics[metric] == null) metrics[metric] = 1			else metrics[metric]++					}			}	}