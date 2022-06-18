package dectiss;

class Parser {
	public static var space = matchSimple.bind(~/\s/mg);
	public static var digit = matchSimple.bind(~/\d/mg);
	public static var alpha = matchSimple.bind(~/[a-z]/img);
	public static var capital = matchSimple.bind(~/[A-Z]/mg);
	public static var uncapital = matchSimple.bind(~/[a-z]/mg);

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
		return (text:String, start:Int) -> {
			var pos = 0;
			var content = "";
			var capture = rule(text, start);

			switch (capture) {
				case None:
					return None;
				case Some(data):
					pos += data.capture.length;
					content += data.capture;
			};

			var capture = ruleb(text, start + pos);

			return switch (capture) {
				case None:
					return None;
				case Some(data):
					Some(new ParseData(content + data.capture));
			};
		}
	}

	public static function or(rule:Rule, ruleb:Rule):Rule {
		return (text:String, start:Int) -> {
			var capture = rule(text, start);

			switch (capture) {
				case Some(data):
					return capture;
				case None:
			};

			return ruleb(text, start);
		}
	}

	// logic functions

	private static function matchSimple(rule:EReg, text:String, start:Int):ParseResult {
		if (rule.matchSub(text, start) && rule.matchedPos().pos == start) {
			return Some(new ParseData(rule.matched(0)));
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
				case Some(data):
					totalCapture += data.capture;
					count++;
			}
		}

		if (count < min) {
			return None;
		}

		return Some(new ParseData(totalCapture));
	}
}
