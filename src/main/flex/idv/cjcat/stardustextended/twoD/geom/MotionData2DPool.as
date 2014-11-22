﻿package idv.cjcat.stardustextended.twoD.geom {
	
	public class MotionData2DPool {
		
		private static var _vec:Vector.<MotionData2D> = new <MotionData2D>[new MotionData2D()];
		private static var _position:int = 0;

		[Inline]
		public static function get(x:Number = 0, y:Number = 0):MotionData2D {
			if (_position == _vec.length) {
				_vec.length <<= 1;
				//trace("MotionData2DPool expanded");
				for (var i:int = _position; i < _vec.length; i++) {
					_vec[i] = new MotionData2D();
				}
			}
			_position++;
			var obj:MotionData2D = _vec[_position - 1];
			obj.x = x;
			obj.y = y;
			return obj;
		}

		[Inline]
		public static function recycle(obj:MotionData2D):void {
			if (_position == 0) return;
			if (!obj) return;
			
			_vec[_position - 1] = obj;
			if (_position) _position--;
		}
	}
}