package net.sakri.flash.bitmap{
	import __AS3__.vec.Vector;
	
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	//import net.sakri.flex.component.FlexSimpleTraceBox;	
	
	public class MarchingSquares9Grid{
		
		//update this when working with large shapes
		//the "edge detection loop" stops at this figure. This is in place in the event that an infinate loop somehow manifests itself.
		public static var MAX_POINTS:uint=10000;//Failsafe
		
		//I've yet to implement a counter clockwise lookup table for this
		//feel free to implement it yourself if deemed necessary (and let me know ;) sakri.rosenstrom AT gmail.com)
		private static var _variations:Object={
								"000110110":new Point(0,1),
								"111110000":new Point(-1,0),
								"111011011":new Point(0,-1),
								"111111110":new Point(0,1),
								"100111111":new Point(1,0),
								"011011011":new Point(0,-1),
								"011011000":new Point(0,-1),
								"110111111":new Point(1,0),
								"011011111":new Point(0,-1),
								"000111111":new Point(1,0),
								"110110100":new Point(-1,0),
								"111111000":new Point(-1,0),
								"111111001":new Point(-1,0),
								"111110100":new Point(-1,0),
								"100110110":new Point(0,1),
								"100110111":new Point(0,1),
								"000110111":new Point(0,1),
								"011111111":new Point(0,-1),
								"000011011":new Point(1,0),
								"110110110":new Point(0,1),
								"110110111":new Point(0,1),
								"011011001":new Point(0,-1),
								"111011000":new Point(0,-1),
								"111111011":new Point(-1,0),
								"000011111":new Point(1,0),
								"111110110":new Point(0,1),
								"110110000":new Point(-1,0),
								"001011111":new Point(1,0),
								"001111111":new Point(1,0),
								"111011001":new Point(0,-1),
								"001011011":new Point(1,0),
								"111111100":new Point(-1,0),
								
								"001110110":new Point(0,1),
								"110110001":new Point(-1,0),
								"100011011":new Point(1,0),
								"011011100":new Point(0,-1)
								}	


		private static var _scan_points:Vector.<Point>=Vector.<Point>([
																new Point(-1,-1),
																new Point(0,-1),
																new Point(1,-1),
																new Point(-1,0),
																new Point(0,0),
																new Point(1,0),
																new Point(-1,1),
																new Point(0,1),
																new Point(1,1)
																	]);

		
		//should be in a BitmapDataUtils class, but moved here for convenience
		public static function getFirstNonTransparentPixel( bmd:BitmapData, start_y:uint=0 ):Point{
			var hit_rect:Rectangle=new Rectangle(0,0,bmd.width,1);
			var p:Point = new Point();
			for( hit_rect.y = start_y; hit_rect.y < bmd.height; hit_rect.y++ ){
				if( bmd.hitTest( p, 0x01, hit_rect) ){
				var hit_bmd:BitmapData=new BitmapData( bmd.width, 1, true, 0 );
				hit_bmd.copyPixels( bmd, hit_rect, p );
				return hit_rect.topLeft.add( hit_bmd.getColorBoundsRect(0xFF000000, 0, false).topLeft );
				}
			}
			return null;
		}
		
		public static function getBlobOutlinePoints(source_bmd:BitmapData):Vector.<Point>{
			var bmd:BitmapData=new BitmapData(source_bmd.width*2,source_bmd.height*2,true,0x00);
			var m:Matrix=new Matrix();
			m.scale(2,2);
			bmd.draw(source_bmd,m);
			var first_non_trans:Point=getFirstNonTransparentPixel(bmd);//move back and up one
			var points:Vector.<Point>=new Vector.<Point>();
			if(first_non_trans==null)return points;
			var position:Point=first_non_trans;
			var grid:String=getGridStringFromPoint(bmd,position);
			points[0]=first_non_trans;
			var next:Point;
			var i:uint=0;
			while(++i<MAX_POINTS){
				next=getNextEdgePoint(_variations,position,grid);
				if(next.equals(first_non_trans))break;
				points[i]=next;
				position=next;
				grid=getGridStringFromPoint(bmd,position);;
			}
			if(i>=MAX_POINTS){
				throw new Error("MarchingSquares9Grid Error : iterated over limit MAX_POINTS : "+MAX_POINTS+" apologies :( ");
			}
			return points;
		}
				
		private static function getGridStringFromPoint(bmd:BitmapData,position:Point):String{
			var stri:String="";
			var p:Point;
			for(var i:uint=0;i<9;i++){
				p=_scan_points[i];
				stri+=(bmd.getPixel32(position.x+p.x,position.y+p.y)>0x0 ? "1" : "0");
			}
			return stri;
		}
				
		private static function getNextEdgePoint(variations:Object,position:Point,grid:String):Point{
			var p:Point=_variations[grid];
			if(p==null)throw new Error("MarchingSquares Error : grid:"+grid+" , not found in _variations");
			return new Point(position.x+p.x,position.y+p.y);
		}

	}
}