package trackers.partialGesture.gestures 
{
	import com.tastenkunst.airkinectv2.KV2Body;
	import com.tastenkunst.airkinectv2.KV2Joint;
	import flash.display.Sprite;
	import trackers.Gesture;
	import trackers.partialGesture.GesturePartResult;
	/**
	 * ...
	 * @author 20secondstosun
	 */

	public class TimeFixedGesture extends Sprite implements IGesture
	{
		protected var FRAMES_FOR_DETECT:int = 400;
		
		protected var frameCount:int = 0;
		protected var segment:IGestureSegment;		
		protected var gesture:Gesture;			
		
		public function getGesture():Gesture
		{
			return gesture;
		}
		
		public function update(joints:Vector.<KV2Joint>, body:KV2Body):int
		{
			var result:int = segment.update(joints, body);
			
			if (result == GesturePartResult.SUCCEEDED)
			{
				if (++frameCount > FRAMES_FOR_DETECT)
				{				
					reset();
					return GesturePartResult.SUCCEEDED;
				}
			}
			else
				reset();
			
			return GesturePartResult.FAILED;
		}
		
		public function reset():void
		{
			frameCount = 0;
		}
		
		public function flush():void
		{
			reset();
		}
	}
}