package trackers.partialGesture.gestures 
{
	import com.tastenkunst.airkinectv2.KV2Body;
	import com.tastenkunst.airkinectv2.KV2Joint;
	/**
	 * ...
	 * @author 20secondstosun
	 */
	
	public interface IGestureSegment
    {
        function update(joints:Vector.<KV2Joint>, body:KV2Body):int;       
    }
}