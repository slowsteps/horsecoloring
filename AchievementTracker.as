﻿package  {		import flash.display.MovieClip;	import flash.geom.ColorTransform;	import flash.events.MouseEvent;	import flash.events.Event;	import fl.transitions.Tween; 	import fl.transitions.easing.*;			public class AchievementTracker extends MovieClip {				var achievements:Object = new Object();				public function AchievementTracker() {			achievements.colorsselected = new Object();			achievements.colorsselected.blue = 4;			achievements.clicks = 6		}				public function Track(akey,avalue=null) {			if (akey == "clicks") {				achievements.clicks++;			}			if (akey =="color") {				achievements.colorsselected[avalue]++;			}		}					}	}