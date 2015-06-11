package trackers.partialGesture.gestures.wave
{
	import com.tastenkunst.airkinectv2.KV2Body;
	import com.tastenkunst.airkinectv2.KV2Joint;
	import trackers.partialGesture.GesturePartResult;
	import trackers.partialGesture.gestures.IGestureSegment;
	
	/**
	 * ...
	 * @author 20secondstosun
	 */
	
	public class WaveSegment2 implements IGestureSegment
	{	
		public function update(joints:Vector.<KV2Joint>, body:KV2Body):int
		{
			var handleft:KV2Joint = JointHelper.findJoint(joints, KV2Joint.JointType_HandLeft);
			var elbow:KV2Joint = JointHelper.findJoint(joints, KV2Joint.JointType_ElbowLeft);
			
			if (handleft.colorSpacePoint.y < elbow.colorSpacePoint.y)
				if (handleft.colorSpacePoint.x < elbow.colorSpacePoint.x)
					return GesturePartResult.SUCCEEDED;
			
			return GesturePartResult.FAILED;
		}		
	}
}