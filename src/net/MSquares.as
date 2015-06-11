package net
{
	import flash.display.Sprite;
	import flash.display.BitmapData;
	import flash.display.Bitmap;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	public class MSquares
	{
		// tolerance is the amount of alpha for a pixel to be considered solid
		private static var tolerance:Number = 0x01;		
		
		public static function marchingSquares(bitmapData:BitmapData):Vector.<Point>
		{
			var contourVector:Vector.<Point> = new Vector.<Point>();
			// this is the canvas we'll use to draw the contour
			var canvas:Sprite = new Sprite();
			//addChild(canvas);
			canvas.graphics.lineStyle(2, 0x00ff00);
			// getting the starting pixel
			var startPoint:Point = getStartingPixel(bitmapData);
			// if we found a starting pixel we can begin
			if (startPoint != null)
			{
				// moving the graphic pen to the starting pixel
				canvas.graphics.moveTo(startPoint.x, startPoint.y);
				// pX and pY are the coordinates of the starting point
				var pX:Number = startPoint.x;
				var pY:Number = startPoint.y;
				// stepX and stepY can be -1, 0 or 1 and represent the step in pixels to reach
				// next contour point
				var stepX:Number;
				var stepY:Number;
				// we also need to save the previous step, that's why we use prevX and prevY
				var prevX:Number;
				var prevY:Number;
				// closedLoop will be true once we traced the full contour
				var closedLoop:Boolean = false;
				while (!closedLoop)
				{
					// the core of the script is getting the 2x2 square value of each pixel
					var squareValue:Number = getSquareValue(bitmapData, pX, pY);
					switch (squareValue)
					{
					/* going UP with these cases:
					
					   +---+---+   +---+---+   +---+---+
					   | 1 |   |   | 1 |   |   | 1 |   |
					   +---+---+   +---+---+   +---+---+
					   |   |   |   | 4 |   |   | 4 | 8 |
					   +---+---+  	+---+---+  	+---+---+
					
					 */
					case 1: 
					case 5: 
					case 13: 
						stepX = 0;
						stepY = -1;
						break;
					/* going DOWN with these cases:
					
					   +---+---+   +---+---+   +---+---+
					   |   |   |   |   | 2 |   | 1 | 2 |
					   +---+---+   +---+---+   +---+---+
					   |   | 8 |   |   | 8 |   |   | 8 |
					   +---+---+  	+---+---+  	+---+---+
					
					 */
					case 8: 
					case 10: 
					case 11: 
						stepX = 0;
						stepY = 1;
						break;
					/* going LEFT with these cases:
					
					   +---+---+   +---+---+   +---+---+
					   |   |   |   |   |   |   |   | 2 |
					   +---+---+   +---+---+   +---+---+
					   | 4 |   |   | 4 | 8 |   | 4 | 8 |
					   +---+---+  	+---+---+  	+---+---+
					
					 */
					case 4: 
					case 12: 
					case 14: 
						stepX = -1;
						stepY = 0;
						break;
					/* going RIGHT with these cases:
					
					   +---+---+   +---+---+   +---+---+
					   |   | 2 |   | 1 | 2 |   | 1 | 2 |
					   +---+---+   +---+---+   +---+---+
					   |   |   |   |   |   |   | 4 |   |
					   +---+---+  	+---+---+  	+---+---+
					
					 */
					case 2: 
					case 3: 
					case 7: 
						stepX = 1;
						stepY = 0;
						break;
					case 6: 
						/* special saddle point case 1:
						
						   +---+---+
						   |   | 2 |
						   +---+---+
						   | 4 |   |
						   +---+---+
						
						   going LEFT if coming from UP
						   else going RIGHT
						
						 */
						if (prevX == 0 && prevY == -1)
						{
							stepX = -1;
							stepY = 0;
						}
						else
						{
							stepX = 1;
							stepY = 0;
						}
						break;
					case 9: 
						/* special saddle point case 2:
						
						   +---+---+
						   | 1 |   |
						   +---+---+
						   |   | 8 |
						   +---+---+
						
						   going UP if coming from RIGHT
						   else going DOWN
						
						 */
						if (prevX == 1 && prevY == 0)
						{
							stepX = 0;
							stepY = -1;
						}
						else
						{
							stepX = 0;
							stepY = 1;
						}
						break;
					}
					// moving onto next point
					pX += stepX;
					pY += stepY;
					// saving contour point
					contourVector.push(new Point(pX, pY));
					prevX = stepX;
					prevY = stepY;
					//  drawing the line
					canvas.graphics.lineTo(pX, pY);
					// if we returned to the first point visited, the loop has finished
					if (pX == startPoint.x && pY == startPoint.y)
					{
						closedLoop = true;
					}
				}
			}
			return contourVector;
		}
		
		private static function getStartingPixel(bitmapData:BitmapData):Point
		{
			// finding the starting pixel is a matter of brute force, we need to scan
			// the image pixel by pixel until we find a non-transparent pixel
			var zeroPoint:Point = new Point(0, 0);
			var offsetPoint:Point = new Point(0, 0);
			for (var i:Number = 0; i < bitmapData.height; i++)
			{
				for (var j:Number = 0; j < bitmapData.width; j++)
				{
					offsetPoint.x = j;
					offsetPoint.y = i;
					//trace(offsetPoint.x, offsetPoint.y);
					if (bitmapData.hitTest(zeroPoint, tolerance, offsetPoint))
					{
						return offsetPoint;
					}
				}
			}
			return null;
		}
		
		private static function getSquareValue(bitmapData:BitmapData, pX:Number, pY:Number):Number
		{
			/*
			
			   checking the 2x2 pixel grid, assigning these values to each pixel, if not transparent
			
			   +---+---+
			   | 1 | 2 |
			   +---+---+
			   | 4 | 8 | <- current pixel (pX,pY)
			   +---+---+
			
			 */
			var squareValue:Number = 0;
			// checking upper left pixel
			if (getAlphaValue(bitmapData.getPixel32(pX - 1, pY - 1)) >= tolerance)
			{
				squareValue += 1;
			}
			// checking upper pixel
			if (getAlphaValue(bitmapData.getPixel32(pX, pY - 1)) > tolerance)
			{
				squareValue += 2;
			}
			// checking left pixel
			if (getAlphaValue(bitmapData.getPixel32(pX - 1, pY)) > tolerance)
			{
				squareValue += 4;
			}
			// checking the pixel itself
			if (getAlphaValue(bitmapData.getPixel32(pX, pY)) > tolerance)
			{
				squareValue += 8;
			}
			return squareValue;
		}
		
		private static function getAlphaValue(n:Number):Number
		{
			// given an ARGB color value, returns the alpha 0 -> 255
			return n >> 24 & 0xFF;
		}
	}
}