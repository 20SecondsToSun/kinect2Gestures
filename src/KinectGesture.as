package
{
	import com.greensock.TweenLite;
	import com.tastenkunst.airkinectv2.examples.KV2Example;
	import com.tastenkunst.airkinectv2.KV2Body;
	import com.tastenkunst.airkinectv2.KV2Code;
	import com.tastenkunst.airkinectv2.KV2Joint;
	import com.tastenkunst.as3.utils.DrawingUtils;
	import flash.display.Bitmap;
	import flash.display.Graphics;
	import flash.display.PixelSnapping;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import trackers.fingersTracking.FingerTracking;
	import trackers.oneDollarGeture.OneDollarGestureTracking;
	import trackers.partialGesture.gestures.handBlink.HandBlinkLeftGesture;
	import trackers.partialGesture.gestures.handUpHead.LeftHandUpHeadGesture;
	import trackers.partialGesture.gestures.handUpHead.RightHandUpHeadGesture;
	import trackers.partialGesture.gestures.twoFingers.TwoFingersLeftGesture;
	import trackers.partialGesture.gestures.twoFingers.TwoFingersRightGesture;
	import trackers.partialGesture.gestures.wave.WaveGesture;
	import trackers.partialGesture.PartialGestureTracking;
	import trackers.TrackerEvent;
	
	public class KinectGesture extends KV2Example
	{
		public var _bmColor:Bitmap;
		public var _bmDepth:Bitmap;
		public var _bmBodyIndexFrame:Bitmap;
		public var _bmDepthFrameMappedToColorSpace:Bitmap;
		public var _bmBodyIndexFrameMappedToColorSpace:Bitmap;
		
		public var _drawSprite:Sprite;
		public var _draw:Graphics;
		public var _tmpPoint:Point;
		
		private var fingerRightTracking:FingerTracking;
		private var fingerLeftTracking:FingerTracking;
		
		private var figureGestureTracking:OneDollarGestureTracking;
		private var partialGestureTracking:PartialGestureTracking
		
		private static const GESTURE_PAUSE_TIME:Number = 1.5;
		private var gestureUpdate:Boolean = true;
		
		
		private var debugField:TextField = new TextField();
		private var format1:TextFormat = new TextFormat("Arial", 60, 0xff0000);
		
		public function KinectGesture()
		{	
			debugField.x = 500;		
			debugField.y = 200;		
			debugField.width = 800;		
			super();
		}
		
		override public function init():void
		{
			_kv2Config.enableColorFrame = true;
			_kv2Config.enableDepthFrame = true;
			_kv2Config.enableBodyIndexFrame = true;
			_kv2Config.enableBodyFrame = true;
			
			_kv2Config.enableColorFrameMappingToDepthSpace = true;
			_kv2Config.enableDepthFrameMappingToColorSpace = false;
			_kv2Config.enableBodyIndexFrameMappingToColorSpace = true;
			
			initKinect();
		}
		
		override protected function onKinectStarted():void
		{
			initKinectChannels();
			initGraphics();
			initStats();
			initTrackers();
			
			addChild(debugField);
			
			addEventListener(Event.EXIT_FRAME, onEnterFrame);
		}
		
		private function initKinectChannels():void
		{
			_bmColor = new Bitmap(_kv2Manager.colorFrameBmd, PixelSnapping.AUTO, true);
			_bmDepth = new Bitmap(_kv2Manager.depthFrameBmd, PixelSnapping.AUTO, true);
			_bmBodyIndexFrame = new Bitmap(_kv2Manager.bodyIndexFrameBmd, PixelSnapping.AUTO, true);
			
			_bmDepthFrameMappedToColorSpace = new Bitmap(_kv2Manager.depthFrameMappedToColorSpaceBmd, PixelSnapping.AUTO, true);
			_bmBodyIndexFrameMappedToColorSpace = new Bitmap(_kv2Manager.bodyIndexFrameMappedToColorSpaceBmd, PixelSnapping.AUTO, true);
			
			_bmColor.visible = _kv2Config.enableColorFrame;
			_bmDepth.visible = _kv2Config.enableDepthFrame;
			_bmBodyIndexFrame.visible = _kv2Config.enableBodyIndexFrame;
			
			_bmDepthFrameMappedToColorSpace.visible = _kv2Config.enableDepthFrameMappingToColorSpace;
			_bmBodyIndexFrameMappedToColorSpace.visible = _kv2Config.enableBodyIndexFrameMappingToColorSpace;
			
			addChild(_bmColor);
			addChild(_bmBodyIndexFrameMappedToColorSpace);
			addChild(_bmDepth);
			addChild(_bmBodyIndexFrame);			
		}
		
		private function initGraphics():void
		{
			_tmpPoint = new Point();
			_drawSprite = new Sprite();
			_draw = _drawSprite.graphics;
			addChild(_drawSprite);
		}
		
		private function initStats():void
		{
			addChild(_stats);
		}
		
		private function initTrackers():void
		{
			fingerRightTracking = new FingerTracking();
			//fingerRightTracking.addEventListener(TrackerEvent.FINGER_TRACK, trackerHandler);
			addChild(fingerRightTracking);
			
			fingerLeftTracking = new FingerTracking();
			//fingerLeftTracking.addEventListener(TrackerEvent.FINGER_TRACK, trackerHandler);
			addChild(fingerLeftTracking);
			
			figureGestureTracking = new OneDollarGestureTracking();
			figureGestureTracking.addEventListener(TrackerEvent.GESTURE_TRACK, trackerHandler);
			addChild(figureGestureTracking);
			
			partialGestureTracking = new PartialGestureTracking();
			partialGestureTracking.registerGesture(new LeftHandUpHeadGesture());
			partialGestureTracking.registerGesture(new RightHandUpHeadGesture());
			partialGestureTracking.registerGesture(new TwoFingersLeftGesture());
			partialGestureTracking.registerGesture(new TwoFingersRightGesture());
			partialGestureTracking.registerGesture(new HandBlinkLeftGesture());
			
			partialGestureTracking.addEventListener(TrackerEvent.GESTURE_TRACK, trackerHandler, false);
			addChild(partialGestureTracking);
		}
		
		private function trackerHandler(e:TrackerEvent):void
		{
			if (e.type == TrackerEvent.FINGER_TRACK)
			{
				trace("fingers : " + e.getGesture().getType());	
				debugField.text = "fingers : " + e.getGesture().getType();
				debugField.setTextFormat(format1);
			}
			else if (e.type == TrackerEvent.GESTURE_TRACK)
			{
				trace("gesture : " + e.getGesture().getName());
				
				debugField.text = e.getGesture().getName();
				debugField.setTextFormat(format1);
			}
			
			partialGestureTracking.flushAll();
			figureGestureTracking.flushAll();
			fingerLeftTracking.flushAll();
			fingerRightTracking.flushAll();
			
			TweenLite.killDelayedCallsTo(pauseCompleteHandler);
			TweenLite.delayedCall(GESTURE_PAUSE_TIME, pauseCompleteHandler);
			gestureUpdate = false;
		}
		
		private function pauseCompleteHandler():void 
		{
			debugField.text = "";
			debugField.setTextFormat(format1);
			gestureUpdate = true;		
		}
		
		override protected function onEnterFrame(event:Event):void
		{			
			if (_kv2Manager.updateImages() == KV2Code.FAIL)
				return;
			
			if (_kv2Manager.updateBodies() == KV2Code.FAIL)
				return;
				
			if (!gestureUpdate)
				return;
			
			var bodies:Vector.<KV2Body> = _kv2Manager.bodies;
			var body:KV2Body;
			var joints:Vector.<KV2Joint>;
			var joint:KV2Joint;
			var scale:Number = _bmColor.scaleX;
			var radius:Number = 10 * scale;
			
			_draw.clear();
			
			for (var i:int = 0, l:int = bodies.length; i < l; ++i)
			{
				body = bodies[i];
				
				if (body.tracked)
				{
					joints = body.joints;
					
					for (var j:int = 0, m:int = joints.length; j < m; ++j)
					{
						joint = joints[j];												
						
						if (joint.jointType == KV2Joint.JointType_HandLeft)
						{
							drawHand(joint, body);
							//if (body.handLeftState == KV2Body.HandState_Lasso)// && body.handLeftConfidence == KV2Body.TrackingConfidence_High)							
							//fingerLeftTracking.updateImage(_bmBodyIndexFrame, joints, joint);
						}
						else if (joint.jointType == KV2Joint.JointType_HandRight)
						{
							//drawHand(joint);
							//fingerRightTracking.updateImage(_bmBodyIndexFrame, joints, joint);
						}
						
						figureGestureTracking.update(joints, body);
						partialGestureTracking.update(joints, body);
					}
				}
			}
		}
		
		private function drawHand(joint:KV2Joint, body:KV2Body):void
		{
			var p:Point = _tmpPoint;
			p.x = joint.depthSpacePoint.x;
			p.y = joint.depthSpacePoint.y;
			var handRadius:Number = 10;
		
			DrawingUtils.drawPoint(_draw, p, handRadius, false, getHandColor(body));
		}
		
		private function getHandColor(body:KV2Body):uint
		{
			var color:uint = 0x00ff00;
			
			if (body.handLeftState == KV2Body.HandState_Closed)// && body.handLeftConfidence == KV2Body.TrackingConfidence_High)
				color = 0xff0000;
			
			if (body.handLeftState == KV2Body.HandState_Lasso)// && body.handLeftConfidence == KV2Body.TrackingConfidence_High)
				color = 0xffff00;
			
			return color;
		}
	}
}