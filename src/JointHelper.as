package
{
	import com.tastenkunst.airkinectv2.KV2Joint;
	
	/**
	 * ...
	 * @author 20secondstosun
	 */
	public class JointHelper
	{
		public static function findJoint(joints:Vector.<KV2Joint>, jointType:int):KV2Joint
		{
			for (var j:int = 0, m:int = joints.length; j < m; ++j)
				if (joints[j].jointType == jointType)
					return joints[j];
			
			return null;
		}
	}
}