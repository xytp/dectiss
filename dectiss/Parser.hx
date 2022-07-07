package dectiss;

import dectiss.ParseResult;

using StringTools;
using dectiss.Utils;

class Parser {
	public static var space = matchEreg.bind(~/\s/mg);
	public static var digit = matchEreg.bind(~/\d/mg);
	public static var alpha = matchEreg.bind(~/[a-z]/img);
	public static var capital = matchEreg.bind(~/[A-Z]/mg);
	public static var uncapital = matchEreg.bind(~/[a-z]/mg);

	public static function char(rule:String):Rule {
		return matchChar.bind(rule);
	}

	public static function string(rule:String):Rule {
		return matchString.bind(rule);
	}

	public static function custom(rule:EReg):Rule {
		return matchEreg.bind(rule);
	}

	public static function optionnal(rule:Rule):Rule {
		return matchMultiple.bind(rule, 0, 1);
	}

	public static function any(rule:Rule):Rule {
		return matchMultiple.bind(rule, 0, null);
	}

	public static function many(rule:Rule):Rule {
		return matchMultiple.bind(rule, 1, null);
	}

	public static function times(rule:Rule, times:Int):Rule {
		return matchMultiple.bind(rule, times, times);
	}

	public static function ranged(rule:Rule, min:Int, max:Null<Int> = null):Rule {
		return matchMultiple.bind(rule, min, max);
	}

	public static function then(rule:Rule, ruleb:Rule):Rule {
		return group([rule, ruleb]);
	}

	public static function or(rule:Rule, ruleb:Rule):Rule {
		return first([rule, ruleb]);
	}

	public static function group(rules:Array<Rule>):Rule {
		return (text:String, start:Int) -> {
			var pos = 0;
			var content:Array<ParseResult> = [];

			for (rule in rules) {
				var capture = rule(text, start + pos);

				switch (capture) {
					case [None]:
						return capture;
					case _:
						for (data in datas) {
							pos += data.capture.length;
							content.push(capture);
						}
				};
			}

			return content;
		}
	}

	public static function first(rules:Array<Rule>):Rule {
		return (text:String, start:Int) -> {
			for (rule in rules) {
				var capture = rule(text, start);

				switch (capture) {
					case None:
						continue;
					case Some(datas):
						return capture;
				};
			}

			return None;
		}
	}

	// logic functions

	private static function matchEreg(rule:EReg, text:String, start:Int):Array<ParseResult> {
		if (rule.matchSub(text, start) && rule.matchedPos().pos == start) {
			return Some(new ParseData(rule.matched(0))).singleton();
		}

		return None;
	}

	private static function matchChar(rule:String, text:String, start:Int):Array<ParseResult> {
		var part = text.charAt(start);

		if (rule.contains(part)) {
			return Some(new ParseData(part)).singleton();
		}

		return None;
	}

	private static function matchString(rule:String, text:String, start:Int):Array<ParseResult> {
		var part = text.substr(start, rule.length);

		if (rule == part) {
			return Some(new ParseData(part)).singleton();
		}

		return None;
	}

	private static function matchMultiple(rule:Rule, min:Int, max:Null<Int>, text:String, start:Int):ParseResult {
		var totalCapture = "";
		var count = 0;

		while (max == null || max > count) {
			var capture = rule(text, start + totalCapture.length);
			switch (capture) {
				case None:
					break;
				case Some(datas):
					for (data in datas) {
						totalCapture += data.capture;
					}

					count++;
			}
		}

		if (count < min) {
			return None;
		}

		return Some(new ParseData(totalCapture).singleton());
	}
}
