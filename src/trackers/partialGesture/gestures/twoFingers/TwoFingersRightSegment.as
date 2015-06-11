package trackers.partialGesture.gestures.twoFingers
{
	import com.tastenkunst.airkinectv2.KV2Body;
	import com.tastenkunst.airkinectv2.KV2Joint;
	import trackers.partialGesture.GesturePartResult;
	import trackers.partialGesture.gestures.IGestureSegment;
	
	/**
	 * ...
	 * @author 20secondstosun
	 */
	public class TwoFingersRightSegment implements IGestureSegment
	{
		public function update(joints:Vector.<KV2Joint>, body:KV2Body):int
		{
			var hand:KV2Joint = JointHelper.findJoint(joints, KV2Joint.JointType_HandRight);
			var head:KV2Joint = JointHelper.findJoint(joints, KV2Joint.JointType_Head);
		
			if (hand.colorSpacePoint.y < head.colorSpacePoint.y && body.handRightState == KV2Body.HandState_Lasso)
				return GesturePartResult.SUCCEEDED;
			
			return GesturePartResult.FAILED;
		}
	}
}