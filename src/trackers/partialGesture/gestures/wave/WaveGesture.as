package trackers.partialGesture.gestures.wave
{
	import com.tastenkunst.airkinectv2.KV2Body;
	import com.tastenkunst.airkinectv2.KV2Joint;
	import flash.display.Sprite;
	import trackers.partialGesture.GesturePartResult;
	import trackers.partialGesture.gestures.IGestureSegment;
	
	/**
	 * ...
	 * @author 20secondstosun
	 */
	public class WaveGesture  extends Sprite implements IPartialGesture
	{
		private static const WINDOW_SIZE:int = 50;
		
		private var segments:Vector.<IGestureSegment>;
		private var currentSegment:int = 0;
		private var frameCount:int = 0;
		
		public function WaveGesture()
		{
			var waveSegment1:WaveSegment1 = new WaveSegment1();
			var waveSegment2:WaveSegment2 = new WaveSegment2();
			segments = new <IGestureSegment>
			[
				waveSegment1, waveSegment2, waveSegment1, waveSegment2, waveSegment1, waveSegment2
			];
		}
		
		public function update(joints:Vector.<KV2Joint>, body:KV2Body):int
		{
			var result:int = segments[currentSegment].update(joints, body);			
			
			if (result == GesturePartResult.SUCCEEDED)
			{
				trace("succeed", currentSegment);
				
				if (currentSegment + 1 < segments.length)
				{
					currentSegment++;
					frameCount = 0;
				}
				else
				{					
					reset();
					return GesturePartResult.SUCCEEDED;
				}				
			}
			else if (result == GesturePartResult.FAILED || frameCount == WINDOW_SIZE)			
				reset();			
			else			
				frameCount++;	
				
			return GesturePartResult.FAILED;
		}
		
		public function reset():void
		{
			currentSegment = 0;
			frameCount = 0;
		}
	}
}