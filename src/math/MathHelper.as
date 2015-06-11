package math 
{
	import flash.geom.Point;
	/**
	 * ...
	 * @author 20secondstosun
	 */
	public class MathHelper 
	{
		
		public static function distanceEuclidean(p1:Point, p2:Point):Number
		{
			var x:Number = (p1.x - p2.x);
			var y:Number = (p1.y - p2.y);
			return Math.sqrt(x * x + y * y);
		}
		
		public static function distanceEuclideanSquared(p1:Point, p2:Point):int
		{
			var x:int = (int)(p1.x - p2.x);
			var y:int = (int)(p1.y - p2.y);
			return (x * x + y * y);
		}
		
		public static function calculateAngle(r1:Point, r2:Point):Number
		{
			return Math.acos((r1.x * r2.x + r1.y * r2.y) / (r1.length * r2.length));
		}
		
	}

}