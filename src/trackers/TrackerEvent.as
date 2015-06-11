package trackers
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	public class TrackerEvent extends Event
	{
		public static const FINGER_TRACK:String = "FINGER_TRACK";
		public static const GESTURE_TRACK:String = "GESTURE_TRACK";
		private var gesture:Gesture;
		
		public function TrackerEvent(gesture:Gesture, type:String, bubbles:Boolean = true, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
			this.gesture = gesture;
		}		
		
		override public function clone():Event
		{
			return new TrackerEvent(gesture, type, bubbles, cancelable);
		}
		
		public function getGesture():Gesture 
		{
			return gesture;
		}
	}
}