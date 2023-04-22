package dectiss;

using Lambda;

class Utils {
	public static inline function singleton<A>(value:A):Array<A> {
		return [value];
	}

	public static function arrayLast<A>(arr:Array<A>):A {
		return arr[arr.length - 1];
	}

	public static macro function literralEReg(content:String) {
		var escaped = ~/[.*+?$^|(){}\-\[\]]/.map(content, (ereg:EReg) -> '\\${ereg.matched(0)}');

		return macro new EReg($v{escaped}, "");
	}

	public static macro function literralAnyEReg(content:String) {
		var escaped = ~/[.*+?$^|(){}\-\[\]]/.map(content, (ereg:EReg) -> '\\${ereg.matched(0)}').split("").join("|");

		return macro new EReg($v{escaped}, "");
	}
}
