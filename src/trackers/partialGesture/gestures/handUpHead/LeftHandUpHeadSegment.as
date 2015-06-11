package trackers.partialGesture.gestures.handUpHead 
{
	import com.tastenkunst.airkinectv2.KV2Body;
	import com.tastenkunst.airkinectv2.KV2Joint;
	import trackers.partialGesture.GesturePartResult;
	import trackers.partialGesture.gestures.IGestureSegment;
	/**
	 * ...
	 * @author 20secondstosun
	 */
	public class LeftHandUpHeadSegment implements IGestureSegment
	{		
		public function update(joints:Vector.<KV2Joint>, body:KV2Body):int
		{
			var handleft:KV2Joint = JointHelper.findJoint(joints, KV2Joint.JointType_HandLeft);
			var head:KV2Joint = JointHelper.findJoint(joints, KV2Joint.JointType_Head);			
		
			if (handleft.colorSpacePoint.y < head.colorSpacePoint.y - 250 && body.handLeftState == KV2Body.HandState_Open)
				return GesturePartResult.SUCCEEDED;
			
			return GesturePartResult.FAILED;
		}		
	}
}