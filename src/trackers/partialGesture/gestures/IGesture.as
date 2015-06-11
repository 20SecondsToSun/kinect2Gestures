package trackers.partialGesture.gestures 
{
	import com.tastenkunst.airkinectv2.KV2Body;
	import com.tastenkunst.airkinectv2.KV2Joint;
	import trackers.Gesture;
	/**
	 * ...
	 * @author 20secondstosun
	 */
	public interface IGesture 
	{		
		function update(joints:Vector.<KV2Joint>, body:KV2Body):int;  
		function getGesture():Gesture;
		function flush():void;		
	}
}