package math
{
	import flash.geom.Point;
	
	public class RDP extends Object
	{		
		public static function rdp(v:Vector.<Point>, epsilon:Number):Vector.<Point>
		{
			var firstPoint:Point = v[0];
			var lastPoint:Point = v[v.length - 1];
			if (v.length < 3)
			{
				return v;
			}
			var index:Number = -1;
			var dist:Number = 0;
			for (var i:Number = 1; i < v.length - 1; i++)
			{
				var cDist:Number = findPerpendicularDistance(v[i], firstPoint, lastPoint);
				if (cDist > dist)
				{
					dist = cDist;
					index = i;
				}
			}
			if (dist > epsilon)
			{
				var l1:Vector.<Point> = v.slice(0, index + 1);
				var l2:Vector.<Point> = v.slice(index);
				var r1:Vector.<Point> = RDP(l1, epsilon);
				var r2:Vector.<Point> = RDP(l2, epsilon);
				var rs:Vector.<Point> = r1.slice(0, r1.length - 1).concat(r2);
				return rs;
			}
			else
			{
				return new Vector.<Point>(firstPoint, lastPoint);
			}
			return null;
		}
		
		private static function findPerpendicularDistance(p:Point, p1:Point, p2:Point):Number
		{
			var result:Number;
			var slope:Number
			var intercept:Number;
			
			if (p1.x == p2.x)
			{
				result = Math.abs(p.x - p1.x);
			}
			else
			{
				slope = (p2.y - p1.y) / (p2.x - p1.x);
				intercept = p1.y - (slope * p1.x);
				result = Math.abs(slope * p.x - p.y + intercept) / Math.sqrt(Math.pow(slope, 2) + 1);
			}
			return result;
		}
	}
}