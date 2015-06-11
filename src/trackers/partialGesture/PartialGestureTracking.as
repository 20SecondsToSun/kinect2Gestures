package trackers.partialGesture
{
	import com.tastenkunst.airkinectv2.KV2Body;
	import com.tastenkunst.airkinectv2.KV2Joint;
	import flash.display.Sprite;
	import trackers.partialGesture.gestures.IGesture;
	import trackers.TrackerEvent;
	
	public class PartialGestureTracking extends Sprite
	{
		private var gestures:Vector.<IGesture> = new Vector.<IGesture>();
		
		public function registerGesture(gesture:IGesture):void
		{
			gestures.push(gesture);
		}
		
		public function update(joints:Vector.<KV2Joint>, body:KV2Body):void
		{
			for (var i:int = 0; i < gestures.length; i++)
			{
				if (gestures[i].update(joints, body) == GesturePartResult.SUCCEEDED)
				{
					dispatchEvent(new TrackerEvent(gestures[i].getGesture(), TrackerEvent.GESTURE_TRACK));
				}
			}
		}
		
		public function flushAll():void
		{
			for (var i:int = 0; i < gestures.length; i++)
				gestures[i].flush();
		}
	
	}
}