package trackers.partialGesture.gestures.handBlink
{
	import com.tastenkunst.airkinectv2.KV2Body;
	import com.tastenkunst.airkinectv2.KV2Joint;
	import trackers.partialGesture.GesturePartResult;
	import trackers.partialGesture.gestures.IGestureSegment;
	
	/**
	 * ...
	 * @author 20secondstosun
	 */
	public class HandBlinkLeftSegment1 implements IGestureSegment
	{
		public function update(joints:Vector.<KV2Joint>, body:KV2Body):int
		{
			var hand:KV2Joint = JointHelper.findJoint(joints, KV2Joint.JointType_HandLeft);
			
			
			if (body.handLeftState == KV2Body.HandState_Open && body.handLeftConfidence == KV2Body.TrackingConfidence_High)
				return GesturePartResult.SUCCEEDED;
			
			return GesturePartResult.FAILED;
		}
	}
}