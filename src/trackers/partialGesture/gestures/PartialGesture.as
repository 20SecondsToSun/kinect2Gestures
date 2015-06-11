package trackers.partialGesture.gestures
{
	import com.tastenkunst.airkinectv2.KV2Body;
	import com.tastenkunst.airkinectv2.KV2Joint;
	import flash.display.Sprite;
	import flash.geom.Vector3D;
	import trackers.Gesture;
	import trackers.partialGesture.GesturePartResult;
	
	/**
	 * ...
	 * @author 20secondstosun
	 */
	
	public class PartialGesture extends Sprite implements IGesture
	{
		protected var FRAMES_FOR_SEGMENT:int = 80;
		
		protected var frameCount:int = 0;
		protected var segments:Vector.<IGestureSegment> = new Vector.<IGestureSegment>();
		protected var gesture:Gesture;
		
		protected var currentSegment:int = 0;
		
		public function getGesture():Gesture
		{
			return gesture;
		}
		
		public function update(joints:Vector.<KV2Joint>, body:KV2Body):int
		{
			var result:int = segments[currentSegment].update(joints, body);
			
			if (result == GesturePartResult.SUCCEEDED)
			{
				//trace(frameCount);
				if (++frameCount < FRAMES_FOR_SEGMENT)
					return GesturePartResult.PROGRESS;
				else reset();
			}
			else
			{
				//trace(currentSegment, frameCount);
				if (frameCount >= 60)
				{
					if (++currentSegment < segments.length)
					{
						return GesturePartResult.PROGRESS;
					}
					else
					{
						reset();
						return GesturePartResult.SUCCEEDED;
					}
				}	
				
			}
			
			reset();
			return GesturePartResult.FAILED;
		}
		
		public function reset():void
		{
			currentSegment = 0;
			frameCount = 0;
		}
		
		public function flush():void
		{
			reset();
		}
	}
}