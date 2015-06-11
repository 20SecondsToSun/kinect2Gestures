package trackers.partialGesture.gestures.handUpHead
{
	import trackers.Gesture;
	import trackers.partialGesture.gestures.TimeFixedGesture;
	
	/**
	 * ...
	 * @author 20secondstosun
	 */
	public class LeftHandUpHeadGesture extends TimeFixedGesture
	{		
		public function LeftHandUpHeadGesture()
		{
			FRAMES_FOR_DETECT = 100;
			gesture = new Gesture(Gesture.HAND_OVER_HEAD);
			segment = new LeftHandUpHeadSegment();
		}
	}
}