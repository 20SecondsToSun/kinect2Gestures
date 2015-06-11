package trackers.partialGesture.gestures.twoFingers
{
	import trackers.Gesture;
	import trackers.partialGesture.gestures.TimeFixedGesture;
	
	/**
	 * ...
	 * @author 20secondstosun
	 */
	public class TwoFingersLeftGesture extends TimeFixedGesture
	{	
		public function TwoFingersLeftGesture()
		{
			gesture = new Gesture(Gesture.TWO_FINGERS);
			segment = new TwoFingersLeftSegment();
		}		
	}
}