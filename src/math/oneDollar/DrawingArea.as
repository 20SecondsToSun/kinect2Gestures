package math.oneDollar
{
	import com.adobe.images.PNGEncoder;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.net.FileReference;
	import flash.utils.ByteArray;

	public class DrawingArea extends Sprite
	{
		private var recognizer:Recognizer;
		protected var isDrawing:Boolean = false;
		protected var x1:int;
		protected var y1:int;
		protected var x2:int;
		protected var y2:int;
		protected var _points:Array;
		
		public var drawColor:uint = 0x000000;
		
		public function DrawingArea()
		{
			recognizer = new Recognizer();			
			
			super();
			
			if (stage == null) 
			{
				addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			} 
			else
			{
				onAddedToStage();
			}			
		}
		
		private function onAddedToStage(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);			
			
			stage.addEventListener(MouseEvent.MOUSE_DOWN, function(event:MouseEvent):void 
			{
				x1 = mouseX;
				y1 = mouseY;
				
				_points = new Array();			
				_points.push(new Point (x1, y1));
				
				isDrawing = true;
				
				graphics.clear();				
				graphics.beginFill(0xffffff, 1);
				graphics.drawRect(0, 0, width, height);
				graphics.endFill();
			});					
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, function(event:MouseEvent):void 
			{
				if (!event.buttonDown)				
					isDrawing = false;						
				
				if (isDrawing)
				{
					x2 = mouseX;
					y2 = mouseY;	
					var p:Point = new Point(x2, y2);
					_points.push(p);
				
					graphics.lineStyle(2, drawColor, 1);					
					graphics.moveTo(x1, y1);
					graphics.lineTo(x2, y2);
					
					x1 = x2;
					y1 = y2;					
				}
			});
			
			addEventListener(MouseEvent.MOUSE_UP, function(event:MouseEvent):void 
			{
				isDrawing = false;
				if (_points.length)
				{
					var result:Result = recognizer.recognize(_points);						
					trace("result.template.name  " + result.template.id);
					trace("result.score  " 		   + result.score);
				}					
			});
		}
		
		public function getPoints():Array 
		{
			return _points;
		}
		
		public function erase():void
		{
			graphics.clear();			
			graphics.beginFill(0xffffff, 0.00001);
			graphics.drawRect(0, 0, width, height);
			graphics.endFill();
		}	
	}
}