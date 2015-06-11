package math.oneDollar
{	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import mx.messaging.channels.StreamingAMFChannel;
	
	public class Result 
	{	
		public var template:Template
		public var score:Number;
		
		public function Result(template:Template, score:Number) // constructor
		{
			this.template=template;
			this.score = score;
		}
	}
}