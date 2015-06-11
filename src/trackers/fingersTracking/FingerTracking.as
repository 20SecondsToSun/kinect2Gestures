package trackers.fingersTracking
{
	import com.greensock.TweenLite;
	import com.tastenkunst.airkinectv2.KV2Joint;
	import com.tastenkunst.as3.utils.DrawingUtils;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Point;
	import math.GrahamScan;
	import math.MathHelper;
	import net.sakri.flash.bitmap.MarchingSquares;
	import trackers.Gesture;
	import trackers.TrackerEvent;
	
	/**
	 * ...
	 * @author 20secondstosun
	 */
	public class FingerTracking extends Sprite
	{
		private static const HAND_WIDTH:int = 100;
		private static const HAND_HEIGHT:int = 100;
		private static const HAND_HEIGHT_HALF:int = 50;
		private static const HAND_WIDTH_HALF:int = 50;
		
		private static const STOP:int = 1;
		private static const TRACK:int = 2;
		private static const PAUSE:int = 3;
		private static const RECKOGNIZE:int = 4;
		
		private var trackingState:int = STOP;
		
		private static const RECOGNIZE_TIME:Number = 2.5;
		private static const PAUSE_TIME:Number = 1.5;
		
		private const K:int = 35;
		private const Theta:Number = 170 * (Math.PI / 180);
		
		private var countur:Sprite;
		private var baseValueHistogram:int;
		private var handCutImage:Bitmap;
		
		private var fingersProb:Vector.<int> = new Vector.<int>(5);
		public var _tmpPoint:Point = new Point();
		
		public var lastFingerIndex:int = -1;
		public var lastFingerSuccessCount:int = 0;
		
		private var gesture:Gesture;
		
		public function FingerTracking()
		{
			var bd:BitmapData = new BitmapData(HAND_WIDTH, HAND_HEIGHT, true, 0x00FFFFFF);
			
			handCutImage = new Bitmap(bd);
			
			gesture = new Gesture();
			countur = new Sprite();
			addChild(countur);
		}
		
		public function updateImage(_bmBodyIndexFrame:Bitmap, joints:Vector.<KV2Joint>, joint:KV2Joint):void
		{
			if (trackingState == PAUSE)
				return;
			
			if (!handPositionReadyForRecognize(joint, joints))
			{
				stop();
				return;
			}
			
			if (trackingState == STOP)
			{
				reset();
			}
			
			var handPoint:Point = joint.depthSpacePoint;
			
			handCutImage.bitmapData = Tools.crop(handPoint.x - HAND_WIDTH_HALF - 5, handPoint.y - HAND_HEIGHT_HALF - 5, HAND_WIDTH - 5, HAND_HEIGHT - 5, _bmBodyIndexFrame).bitmapData;
			handPoint = new Point(HAND_WIDTH_HALF, HAND_HEIGHT_HALF);
			
			try
			{
				var points:Vector.<Point> = MarchingSquares.getBlobOutlinePointsCounterClockwise(handCutImage.bitmapData);
			}
			catch (err:Error)
			{
				return;
			}
			
			if (points && points.length > 100)
			{
				countur.graphics.clear();
				
				var hull:Vector.<Point> = math.GrahamScan.convexHull(points);
				
				countur.graphics.moveTo(hull[0].x, hull[0].y);
				for (var index:int = 1; index < hull.length; index++)
				{
					countur.graphics.lineStyle(2, 0x00ff00, 1);
					countur.graphics.lineTo(hull[index].x, hull[index].y);
				}
				
				findFingers(hull, handPoint);
			}
		}
		
		private function handPositionReadyForRecognize(handJoint:KV2Joint, joints:Vector.<KV2Joint>):Boolean
		{
			var diff:Number = 0;
			var joint:KV2Joint;
			var p:Point = _tmpPoint;
			
			var spineShoulder:KV2Joint = JointHelper.findJoint(joints, KV2Joint.JointType_SpineShoulder);
			var head:KV2Joint = JointHelper.findJoint(joints, KV2Joint.JointType_Head);
			
			var spineDiffZ:Number = spineShoulder.cameraSpacePoint.z - handJoint.cameraSpacePoint.z;
			var headDiffY:Number  = handJoint.colorSpacePoint.y - head.colorSpacePoint.y;
			
			return spineDiffZ > 0.48 && headDiffY > 0;
		}
		
		public function stop():void
		{
			trackingState = STOP;
		}
		
		public function reset():void
		{
			for (var i:int = 0; i < fingersProb.length; i++)
				fingersProb[i] = 0;
			
			trackingState = TRACK;
			
			TweenLite.killDelayedCallsTo(trackCompleteHandler);
			TweenLite.delayedCall(RECOGNIZE_TIME, trackCompleteHandler);
		}
		
		private function trackCompleteHandler():void
		{
			trackingState = PAUSE;
			
			var all:Number = fingersProb[0] + fingersProb[1] + fingersProb[2] + fingersProb[3] + fingersProb[4];
			
			var max:Number = Number.MIN_VALUE;
			var length:uint = fingersProb.length;
			
			var fingerIndex:int = 0;
			
			for (var i:uint = 0; i < length; ++i)
				if (fingersProb[i] > max)
				{
					max = fingersProb[i];
					fingerIndex = i;
				}
			
			if (fingerIndex == 1)
				gesture.setType(Gesture.ONE_FINGER);
			else if (fingerIndex >= 2)
				gesture.setType(Gesture.TWO_FINGERS);
			else
				gesture.setType(Gesture.INVALID);
			
			dispatchEvent(new TrackerEvent(gesture, TrackerEvent.FINGER_TRACK));
			
			TweenLite.killDelayedCallsTo(pauseCompleteHandler);
			TweenLite.delayedCall(PAUSE_TIME, pauseCompleteHandler);
		}
		
		private function pauseCompleteHandler():void
		{
			trackingState = STOP;
		}
		
		private function findFingers(contourPoints:Vector.<Point>, palm:Point):void
		{
			var numPoints:int = contourPoints.length;
			var p1:Point, p2:Point, p3:Point, palm:Point;
			var angle:Number, dp2:Number;
			var distance:Number, depth:Number;
			var count:int = 0;
			
			var candidates:Vector.<Point> = new Vector.<Point>();
			
			for (var i:int = 1; i < numPoints - 1; i++)
			{
				p1 = contourPoints[i - 1];
				p2 = contourPoints[i];
				p3 = contourPoints[i + 1];
				
				angle = MathHelper.calculateAngle(p1.subtract(p2), p3.subtract(p2));
				
				if (angle > 0 && angle < Theta && p2.y < palm.y)
				{
					count++;
					candidates.push(contourPoints[i]);
				}
			}
			
			var epsilon:Number = 10;
			var fingers:Vector.<Point> = new Vector.<Point>();
			
			while (1)
			{
				var ready:Boolean = true;
				for (var j:int = 0; j < candidates.length - 1; j++)
				{
					if (MathHelper.distanceEuclidean(candidates[j], candidates[j + 1]) < epsilon)
					{
						candidates.splice(j, 1);
						ready = false;
					}
				}
				
				if (ready)
					break;
			}
			
			if (candidates.length < 5)
			{
				fingersProb[candidates.length]++;
				
				if (lastFingerIndex != candidates.length)
				{
					lastFingerIndex = candidates.length;
					lastFingerSuccessCount = 0;
				}
				else
				{
					lastFingerSuccessCount++;
					
					if (lastFingerSuccessCount > 10)
					{
						if (!maxFingerProb(lastFingerIndex))
							reset();
					}
				}
			}
			
			for (var m:int = 0; m < candidates.length; m++)
				DrawingUtils.drawPoint(countur.graphics, candidates[m], 4, false, 0xff0000);
		}
		
		private function maxFingerProb(lastFingerIndex:int):Boolean
		{
			for (var i:int = 0; i < fingersProb.length; i++)
			{
				if (i == lastFingerIndex)
					continue;
					
				if (fingersProb[lastFingerIndex] < fingersProb[i])
					return false;
			}
			
			return true;
		}
		
		public function flushAll():void
		{
			
		}
	}
}