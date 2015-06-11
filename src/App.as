package
{
	import flash.desktop.NativeApplication;
	import math.oneDollar.DrawingArea;
	import com.tastenkunst.airkinectv2.examples.*;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	
	[SWF(backgroundColor = "#bbbbbb", frameRate = "60", width = "1420", height = "880")]
	
	public class App extends Sprite
	{
		private var area:DrawingArea;
		public var kinectGesture:KinectGesture;
		
		public function App()
		{
			stage ? onAddedToStage() : addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(event:Event = null):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			NativeApplication.nativeApplication.addEventListener(Event.EXITING, onExit);
          
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.quality = StageQuality.HIGH;
			
			init();
		}
		
		private function onExit(e:Event):void 
		{
			kinectGesture.flush();
		}		
		
		private function init():void
		{
			kinectGesture = new KinectGesture();			
			addChild(kinectGesture);
			kinectGesture.init();
			
			area = new DrawingArea();
			addChild(area);
		}
	}
}