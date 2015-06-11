package trackers.partialGesture.gestures.twoFingers
{
	import trackers.Gesture;
	import trackers.partialGesture.gestures.TimeFixedGesture;
	
	/**
	 * ...
	 * @author 20secondstosun
	 */
	public class TwoFingersRightGesture extends TimeFixedGesture
	{	
		public function TwoFingersRightGesture()
		{
			gesture = new Gesture(Gesture.TWO_FINGERS);
			segment = new TwoFingersRightSegment();
		}		
	}
}