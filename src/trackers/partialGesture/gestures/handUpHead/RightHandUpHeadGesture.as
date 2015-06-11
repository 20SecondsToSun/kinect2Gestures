package trackers.partialGesture.gestures.handUpHead
{
	import flash.display.Sprite;
	import trackers.Gesture;
	import trackers.partialGesture.gestures.IGesture;
	import trackers.partialGesture.gestures.TimeFixedGesture;
	
	/**
	 * ...
	 * @author 20secondstosun
	 */
	public class RightHandUpHeadGesture extends TimeFixedGesture
	{		
		public function RightHandUpHeadGesture()
		{
			FRAMES_FOR_DETECT = 100;
			gesture = new Gesture(Gesture.HAND_OVER_HEAD);
			segment = new RightHandUpHeadSegment();			
		}		
	}
}