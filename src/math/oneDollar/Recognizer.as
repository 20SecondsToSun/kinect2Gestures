package math.oneDollar
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class Recognizer 
	{		
		public static var NumPoints:int = 64;
		public static var SquareSize:Number = 250.0;
		public static var HalfDiagonal:Number = 0.5 * Math.sqrt(250.0 * 250.0 + 250.0 * 250.0);
		public static var AngleRange:Number = 45.0;
		public static var AnglePrecision:Number = 2.0;
		public static var Phi:Number = 0.5 * (-1.0 + Math.sqrt(5.0)); // Golden Ratio
		
		private var data:GestureData;
		public var templates:Array;
		
		public function Recognizer() // constructor
		{ 
			data = new GestureData();
			templates = data.getTemplates();
		}
		
		public function recognize(points:Array):Result
		{
			points = Resample(points, NumPoints);
			points = RotateToZero(points);
			points = ScaleToSquare(points, SquareSize);
			points = TranslateToOrigin(points);
			
			var b:Number = +Infinity;
			var t:uint;
		
			for (var i:int = 0; i < this.templates.length; i++)
			{
				var d:Number = DistanceAtBestAngle(points, this.templates[i], -AngleRange, +AngleRange, AnglePrecision);
				if (d < b)
				{
					b = d;
					t = i;
				}
			}
			var score:Number = 1.0 - (b / HalfDiagonal);
			var result_template:Template=this.templates[t];
			//var testres=new Result(this.templates[t].Name, score);
			return new Result(this.templates[t], score);
			//return result_template.name;
		}
		
		public function templatePoint(points:Array, name:String):Array
		{
			var nPoints:Array;
			nPoints=Resample(points, NumPoints);
			nPoints=RotateToZero(nPoints);
			nPoints=ScaleToSquare(nPoints, SquareSize);
			nPoints=TranslateToOrigin(nPoints);
			return nPoints;
		}
		
		// add/delete new templates
		
		public function addTemplate(id:int, points:Array):Number
		{
			this.templates[this.templates.length] = new Template(id, points); // append new template
			var num:Number = 0;
			for (var i:int = 0; i < this.templates.length; i++)
			{
				if (this.templates[i].id == id)
					num++;
			}
			return num;
		}		
		
		// Helper functions
		
		public static function Resample(points:Array, n:uint):Array
		{
			var I:Number = PathLength(points) / (n - 1); // interval length
			var D:Number = 0.0;
			var newpoints:Array = new Array(points[0]);
			for (var i:int = 1; i < points.length; i++)
			{
				var d:Number = Distance(points[i - 1], points[i]);
				if ((D + d) >= I)
				{
					var qx:Number = points[i - 1].x + ((I - D) / d) * (points[i].x - points[i - 1].x);
					var qy:Number = points[i - 1].y + ((I - D) / d) * (points[i].y - points[i - 1].y);
					var q:Point = new Point(qx, qy);
					newpoints[newpoints.length] = q; // append new point 'q'
					points.splice(i, 0, q); // insert 'q' at position i in points s.t. 'q' will be the next i
					D = 0.0;
				}
				else D += d;
			}
			// somtimes we fall a rounding-error short of adding the last point, so add it if so
			if (newpoints.length == n - 1)
			{
				newpoints[newpoints.length] = points[points.length - 1];
			}
			return newpoints;
		}
		
		public static function RotateToZero(points:Array):Array
		{
			var c:Point = Centroid(points);
			var theta:Number = Math.atan2(c.y - points[0].y, c.x - points[0].x);
			return RotateBy(points, -theta);
		}
		
		public static function ScaleToSquare(points:Array, size:Number):Array
		{
			var B:Rectangle = BoundingBox(points);
			var newpoints:Array = new Array();
			for (var i:int = 0; i < points.length; i++)
			{
				var qx:Number = points[i].x * (size / B.width);
				var qy:Number = points[i].y * (size / B.height);
				newpoints[newpoints.length] = new Point(qx, qy);
			}
			return newpoints;
		}	
		
		public static function TranslateToOrigin(points:Array):Array
		{
			var c:Point = Centroid(points);
			var newpoints:Array = new Array();
			for (var i:int = 0; i < points.length; i++)
			{
				var qx:Number = points[i].x - c.x;
				var qy:Number = points[i].y - c.y;
				newpoints[newpoints.length] = new Point(qx, qy);
			}
			return newpoints;
		}
		
		public static function DistanceAtBestAngle(points:Array, T:Template, a:Number, b:Number, threshold:Number):Number
		{
			var x1:Number = Phi * a + (1.0 - Phi) * b;
			var f1:Number = DistanceAtAngle(points, T, x1);
			var x2:Number = (1.0 - Phi) * a + Phi * b;
			var f2:Number = DistanceAtAngle(points, T, x2);
			while (Math.abs(b - a) > threshold)
			{
				if (f1 < f2)
				{
					b = x2;
					x2 = x1;
					f2 = f1;
					x1 = Phi * a + (1.0 - Phi) * b;
					f1 = DistanceAtAngle(points, T, x1);
				}
				else
				{
					a = x1;
					x1 = x2;
					f1 = f2;
					x2 = (1.0 - Phi) * a + Phi * b;
					f2 = DistanceAtAngle(points, T, x2);
				}
			}
			return Math.min(f1, f2);
		}
		
		public static function PathLength(points:Array):Number
		{
			var d:Number = 0.0;
			for (var i:int = 1; i < points.length; i++)
				d += Distance(points[i - 1], points[i]);
			return d;
		}
		
		public static function Distance(p1:Point, p2:Point):Number
		{
			var dx:Number = p2.x - p1.x;
			var dy:Number = p2.y - p1.y;
			return Math.sqrt(dx * dx + dy * dy);
		}
		
		public static function Centroid(points:Array):Point
		{
			var x:Number = 0.0, y:Number = 0.0;
			for (var i:int = 0; i < points.length; i++)
			{
				x += points[i].x;
				y += points[i].y;
			}
			x /= points.length;
			y /= points.length;
			return new Point(x, y);
		}
		
		public static function RotateBy(points:Array, theta:Number):Array
		{
			var c:Point = Centroid(points);
			var cos:Number = Math.cos(theta);
			var sin:Number = Math.sin(theta);
			
			var newpoints:Array = new Array();
			for (var i:int = 0; i < points.length; i++)
			{
				var qx:Number = (points[i].x - c.x) * cos - (points[i].y - c.y) * sin + c.x
				var qy:Number = (points[i].x - c.x) * sin + (points[i].y - c.y) * cos + c.y;
				newpoints[newpoints.length] = new Point(qx, qy);
			}
			return newpoints;
		}
		
		public static function BoundingBox(points:Array):Rectangle
		{
			var minX:Number = +Infinity, maxX:Number = -Infinity, minY:Number = +Infinity, maxY:Number = -Infinity;
			for (var i:int = 0; i < points.length; i++)
			{
				if (points[i].x < minX)
					minX = points[i].x;
				if (points[i].x > maxX)
					maxX = points[i].x;
				if (points[i].y < minY)
					minY = points[i].y;
				if (points[i].y > maxY)
					maxY = points[i].y;
			}
			return new Rectangle(minX, minY, maxX - minX, maxY - minY);
		}
		
		public static function DistanceAtAngle(points:Array, T:Template, theta:Number):Number
		{
			var newpoints:Array = RotateBy(points, theta);
			return PathDistance(newpoints, T.points);
		}
		
		public static function PathDistance(pts1:Array, pts2:Array):Number
		{
			var d:Number = 0.0;
			for (var i:int = 0; i < pts1.length; i++) // assumes pts1.length == pts2.length
				d += Distance(pts1[i], pts2[i]);
			return d / pts1.length;
		}
		
		public function Deg2Rad(d:Number):Number
		{
			return (d * Math.PI / 180.0);
		}
		
		public function Rad2Deg(r:Number):Number
		{
			return (r * 180.0 / Math.PI);
		}
	}
}