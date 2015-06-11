package
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.PixelSnapping;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	/**
	 * ...
	 * @author 20secondstosun
	 */
	public class Tools
	{
		
		public static function cutPoly(sourceBitmapData:BitmapData, maskShape:Shape, bounds:Rectangle):BitmapData
		{
			// you might not need this, supplying just the sourceBitmap to finalBitmapData.draw(), it should be tested though.
			var sourceBitmapContainer:Sprite = new Sprite();
			sourceBitmapContainer.addChild(sourceBitmap);
			sourceBitmapContainer.addChild(maskShape);
			
			var sourceBitmap:Bitmap = new Bitmap(sourceBitmapData);
			maskShape.x = bounds.x;
			maskShape.y = bounds.y;
			sourceBitmap.mask = maskShape;
			
			var finalBitmapData:BitmapData = new BitmapData(bounds.width, bounds.height, true, 0x00ffffff);
			// or var finalBitmapData:Bitmap = new BitmapData(maskShape.width, maskShape.height); not too sure about the contents of the bounds...
			finalBitmapData.draw(sourceBitmapContainer);
			
			return finalBitmapData;
		}
		
		public static function crop( x:Number, y:Number, _width:Number, _height:Number, displayObject:DisplayObject = null):Bitmap
		{
		   var cropArea:Rectangle = new Rectangle( 0, 0, _width, _height );
		   var croppedBitmap:Bitmap = new Bitmap( new BitmapData( _width, _height, true , 0x00000000), PixelSnapping.ALWAYS, true );
		   croppedBitmap.bitmapData.draw(displayObject, new Matrix(1, 0, 0, 1, -x, -y) , null, null, cropArea, true );
		   return croppedBitmap;
		}
		
		private static function map(value:Number, istart:Number, istop:Number, ostart:Number, ostop:Number):Number
		{
			return ostart + (ostop - ostart) * ((value - istart) / (istop - istart));
		}
 
	
	}

}