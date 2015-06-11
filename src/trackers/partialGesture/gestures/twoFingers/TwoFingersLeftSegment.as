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
	public class TwoFingersLeftSegment implements IGestureSegment
	{
		public function update(joints:Vector.<KV2Joint>, body:KV2Body):int
		{
			var hand:KV2Joint = JointHelper.findJoint(joints, KV2Joint.JointType_HandLeft);
			var head:KV2Joint = JointHelper.findJoint(joints, KV2Joint.JointType_Head);
			//var spine:KV2Joint = JointHelper.findJoint(joints, KV2Joint.JointType_SpineShoulder);	
			
			//	var spineDiffZ:Number = spine.cameraSpacePoint.z - hand.cameraSpacePoint.z;
			//	var headDiffY:Number  = hand.colorSpacePoint.y - head.colorSpacePoint.y;
			
			if (hand.colorSpacePoint.y < head.colorSpacePoint.y 
			//&& hand.colorSpacePoint.y < spine.colorSpacePoint.y 
			&& body.handLeftState == KV2Body.HandState_Lasso)
				//&& spineDiffZ > 0.48 && headDiffY > 0)
				return GesturePartResult.SUCCEEDED;
			
			return GesturePartResult.FAILED;
		}
	}
}