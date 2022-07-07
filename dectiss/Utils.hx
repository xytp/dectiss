package dectiss;

using Lambda;

class Utils {
	public static inline function singleton<A>(value:A):Array<A> {
		return [value];
	}

	public static function dataLength(datas:Array<ParseData>):Int {
		return datas.fold((data, memo) -> memo + data.capture.length, 0);
	}

	public static function dataJoin(datas:Array<ParseData>):String {
		return datas.fold((data, memo) -> memo + data.capture, "");
	}
}
