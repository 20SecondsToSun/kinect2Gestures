package trackers.oneDollarGeture
{
	import com.greensock.TweenLite;
	import com.tastenkunst.airkinectv2.KV2Body;
	import com.tastenkunst.airkinectv2.KV2Joint;
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	import math.oneDollar.Recognizer;
	import math.oneDollar.Result;
	import trackers.Gesture;	
	import trackers.TrackerEvent;	
	
	public class OneDollarGestureTracking extends Sprite
	{
		private static const STOP:int = 1;
		private static const TRACK:int = 2;
		private static const PAUSE:int = 3;
		private static const RECOGNIZE:int = 4;
		
		private static const GESTURE_MAX_TIME:int = 40;
		private static const GESTURE_MIN_TIME:Number = 1.5;
		
		private static const PAUSE_TIME:Number = 0.5;
		
		private var trackingState:int = STOP;
		private var trackingHandType:int;
		private var points:Array;
		
		private var timer:Timer;
		private var gestureTime:Number = 0;
		private var drawColor:uint = 0xfff000;
		private var prevHandPosition:Point;
		
		private var recognizer:Recognizer;
		private var gesture:Gesture;
		
		private var mod:int;
		
		public function OneDollarGestureTracking()
		{	
			recognizer = new Recognizer();
			gesture = new Gesture();
			
			timer = new Timer(100, GESTURE_MAX_TIME);              
            timer.addEventListener(TimerEvent.TIMER, onTick); 
            timer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete); 			
		}
		
		private function onTick(event:TimerEvent):void 
		{	
			gestureTime = event.target.currentCount / 10.0;
		}
		
		private function onTimerComplete(e:TimerEvent):void 
		{
			trackingState = STOP;
			graphics.clear();
		}			
		
		public function startTrack(point:Point):void
		{
			trackingState = TRACK;
			
			points = new Array();
			points.push(point);
			prevHandPosition = point;
			
			graphics.clear();
			graphics.moveTo(point.x, point.y);		
			
			timer.reset();
			timer.start();
			
			gestureTime = 0.0;
			mod = 0;
		}
		
		public function update(joints:Vector.<KV2Joint>, body:KV2Body):void
		{
			switch (trackingState)
			{
			case STOP: 
				tryToStart(joints, body);
				break;
			
			case TRACK: 
				track(joints, body);
				break;
			}
		}
		
		private function tryToStart(joints:Vector.<KV2Joint>, body:KV2Body):void
		{
			var headJoint:KV2Joint = JointHelper.findJoint(joints, KV2Joint.JointType_Head);
			for (var j:int = 0, m:int = joints.length; j < m; ++j)
			{
				if (joints[j].jointType == KV2Joint.JointType_HandLeft || joints[j].jointType == KV2Joint.JointType_HandRight)
					if (body.handLeftState == KV2Body.HandState_Closed && headJoint.colorSpacePoint.y + 10 > joints[j].colorSpacePoint.y)
					{						
						trackingHandType = joints[j].jointType;
						startTrack(joints[j].colorSpacePoint);
						break;
					}
			}
		}
		
		private function track(joints:Vector.<KV2Joint>, body:KV2Body):void
		{
			var headJoint:KV2Joint = JointHelper.findJoint(joints, KV2Joint.JointType_Head);
			var trackingHand:KV2Joint;
			
			for (var j:int = 0, m:int = joints.length; j < m; ++j)
			{
				if (joints[j].jointType == trackingHandType)
				{
					trackingHand = joints[j];
					break;
				}
			}			
			
			var p:Point = new Point(trackingHand.colorSpacePoint.x, trackingHand.colorSpacePoint.y);
		
			if (mod++ % 50 == 0 )
			{
				points.push(p);			
				graphics.lineStyle(5, drawColor, 1);
				graphics.lineTo(p.x, p.y);
			}			
			
			prevHandPosition = new Point(p.x, p.y);		
			
			var handBecomeOpen:Boolean = (trackingHand.jointType == KV2Joint.JointType_HandLeft && body.handLeftState == KV2Body.HandState_Open); 
			
			if ( headJoint.colorSpacePoint.y + 10 > trackingHand.colorSpacePoint.y && (gestureTime > GESTURE_MIN_TIME || handBecomeOpen))
			{			
				//trace("Complete----------------------------", points.length);
				
				if (points.length)
				{
					var result:Result = recognizer.recognize(points);
					if (result.template.id != Gesture.INVALID && result.score > 0.8)
					{
						gesture.setType(result.template.id);
						dispatchEvent(new TrackerEvent(gesture, TrackerEvent.GESTURE_TRACK));
					}				
				}
				
				graphics.clear();
				trackingState = PAUSE;
				
				TweenLite.killDelayedCallsTo(pauseCompleteHandler);
				TweenLite.delayedCall(PAUSE_TIME, pauseCompleteHandler);
			}					
		}		
		
		private function pauseCompleteHandler():void 
		{
			trackingState = STOP;
			timer.stop();
		}
		
		public function flushAll():void
		{
			graphics.clear();
			trackingState = STOP;
			timer.stop();
		}
	}
}