package trackers.partialGesture.gestures.handBlink
{
	import trackers.Gesture;
	import trackers.partialGesture.gestures.PartialGesture;
	
	/**
	 * ...
	 * @author 20secondstosun
	 */
	public class HandBlinkLeftGesture extends PartialGesture
	{	
		public function HandBlinkLeftGesture()
		{
			gesture = new Gesture(Gesture.HAND_BLINK);			
			segments.push(new HandBlinkLeftSegment1());
			segments.push(new HandBlinkLeftSegment2());
			segments.push(new HandBlinkLeftSegment1());
			segments.push(new HandBlinkLeftSegment2());
		}		
	}
}