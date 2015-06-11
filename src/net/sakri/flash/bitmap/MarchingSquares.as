package net.sakri.flash.bitmap{
	import __AS3__.vec.Vector;
	
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;	
	
	public class MarchingSquares{
		
		public static const CLOCKWISE:uint=0;
		public static const COUNTER_CLOCKWISE:uint=1;
		
		//update this when working with large shapes
		//the "edge detection loop" stops at this figure. This is in place in the event that an infinate loop somehow manifests itself.
		public static var MAX_POINTS:uint=10000;//Failsafe
		//
		public static var use_double_size:Boolean=true;
		
		//copied from image in http://en.wikipedia.org/wiki/Marching_squares
		//these are not constants, as dynamic objects can still be manipulated even if set as const
		private static var _variations_ccw:Object={
										"1100":new Point(1,0),
										"0011":new Point(-1,0),
										"1110":new Point(1,0),
										
										"0100":new Point(1,0),
										"1000":new Point(0,-1),
										"1011":new Point(0,-1),
										"1001":new Point(0,-1),
										
										"0101":new Point(0,1),
										"1010":new Point(0,-1),
										"0111":new Point(-1,0),
										"0110":new Point(-1,0),
										
										"0001":new Point(0,1),
										"0010":new Point(-1,0),
										"1101":new Point(0,1)
										};
		private static var _variations_cw:Object={
										"1100":new Point(-1,0),
										"0011":new Point(1,0),
										"1110":new Point(0,1),
										
										"0100":new Point(0,-1),
										"1000":new Point(-1,0),
										"1011":new Point(1,0),
										"1001":new Point(1,0),
										
										"0101":new Point(0,-1),
										"1010":new Point(0,1),
										"0111":new Point(0,-1),
										"0110":new Point(0,-1),
										
										"0001":new Point(1,0),
										"0010":new Point(0,1),
										"1101":new Point(-1,0)
										};

		private static var _direction:uint;

		private static var _scan_point0:Point=new Point(0,0);
		private static var _scan_point1:Point=new Point(1,0);
		private static var _scan_point2:Point=new Point(0,1);
		private static var _scan_point3:Point=new Point(1,1);
		
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
		
		/**
		 * MarchingSquares handles one pixel wide horizontal and vertical lines like a champion
		 * only, thes points along the line are "scanned" twice, meaning the returned vector
		 * of points includes duplicates. This method will remove those pesky little bastards,
		 * ofcourse at a slight performance cost. meh.
		 */
		public static function getUniquePoints(points:Vector.<Point>):Vector.<Point>{
			var unique:Object=new Object();
			var unique_points:Vector.<Point>=new Vector.<Point>()
			var tot:int=points.length;
			var stri:String;
			var p:Point;
			for(var i:uint=0;i<tot;++i){
				p=points[i];
				stri=p.x+":"+p.y;
				if(unique[stri]==null){
					unique[stri]=true;
					unique_points.push(p);
				}
			}
			return unique_points;
		}
		
		public static function getBlobOutlinePointsClockwise(target:BitmapData,check_unique:Boolean=false):Vector.<Point>{
			_direction=CLOCKWISE;
			if(check_unique){
				return getUniquePoints(getPoints(target,_variations_cw));
			}else{
				return getPoints(target,_variations_cw);
			}
		}
		public static function getBlobOutlinePointsCounterClockwise(target:BitmapData,check_unique:Boolean=false):Vector.<Point>{
			_direction=COUNTER_CLOCKWISE;
			if(check_unique){
				return getUniquePoints(getPoints(target,_variations_ccw));				
			}else{
				return getPoints(target,_variations_ccw);
			}
		}
		
		private static function getPoints(bmd:BitmapData, variations:Object):Vector.<Point> {
			var first_non_trans:Point=getFirstNonTransparentPixel(bmd).add(new Point(-1,-1));//move back and up one
			var points:Vector.<Point>=new Vector.<Point>();
			if(first_non_trans==null)return points;
			var position:Point=first_non_trans;
			var grid:String=getGridStringFromPoint(bmd,position);
			points[0]=first_non_trans;
			var next:Point;
			var i:uint=0;
			while(++i<MAX_POINTS){
				next=getNextEdgePoint(variations,position,grid);
				if(next.equals(first_non_trans))break;
				points[i]=next;
				position=next;
				grid=getGridStringFromPoint(bmd,position);;
			}
			if(i>=MAX_POINTS){
				return getPointsMarchingSquares9Grid(bmd);
			}
			return points;
		}
		
		//I've yet to implement a counter clockwise lookup table for MarchingSquares9Grid
		//this reversal might slow things down by a millisecond or two
		//feel free to implement it yourself if deemed necessary (and let me know ;) sakri.rosenstrom AT gmail.com)
		private static function getPointsMarchingSquares9Grid(bmd:BitmapData):Vector.<Point>{
			var points:Vector.<Point>=MarchingSquares9Grid.getBlobOutlinePoints(bmd);
			var i:int=points.length;
			var p:Point;
			if(_direction==CLOCKWISE){
				while(--i>-1){
					p=points[i]
					points[i]=new Point(p.x/2,p.y/2);
				}
				return points;
			}else{
				var reversed:Vector.<Point>=new Vector.<Point>();
				while(--i>-1){
					p=points[i]
					reversed.push(new Point(p.x/2,p.y/2));
				}
				return reversed;				
			}
			return points;
		}
		
		private static function getGridStringFromPoint(bmd:BitmapData,position:Point):String{
			var stri:String=(bmd.getPixel32(position.x+_scan_point0.x,position.y+_scan_point0.y)>0x0 ? "1" : "0")
			stri+=(bmd.getPixel32(position.x+_scan_point1.x,position.y+_scan_point1.y)>0x0 ? "1" : "0")
			stri+=(bmd.getPixel32(position.x+_scan_point2.x,position.y+_scan_point2.y)>0x0 ? "1" : "0")
			stri+=(bmd.getPixel32(position.x+_scan_point3.x,position.y+_scan_point3.y)>0x0 ? "1" : "0")
			return stri;
		}
				
		private static function getNextEdgePoint(variations:Object,position:Point,grid:String):Point{
			var p:Point=variations[grid];
			if(p==null)throw new Error("MarchingSquares Error : grid:"+grid+" , not found in variations");
			return new Point(position.x+p.x,position.y+p.y);
		}

	}
}