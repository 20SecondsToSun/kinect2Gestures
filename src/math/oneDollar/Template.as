package math.oneDollar
{	
	import trackers.Gesture;
	public class Template {
		
		public var id:int;
		public var points:Array;
		
		public function Template(id:int = Gesture.INVALID, points:Array = null) // constructor		
		{
			this.id = id;
			
			if (points && points.length > 1)
			{
				this.points = Recognizer.Resample(points, Recognizer.NumPoints);
				this.points = Recognizer.RotateToZero(this.points);
				this.points = Recognizer.ScaleToSquare(this.points, Recognizer.SquareSize);
				this.points = Recognizer.TranslateToOrigin(this.points);
			}	
		}
	}
}