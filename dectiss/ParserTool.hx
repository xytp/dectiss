package dectiss;

class ParserTool {
	public static function parse(rule:Rule, input:String) {
		var capture = rule(input, 0);
		switch (capture) {
			case None:
				throw 'no match!';
			case Some(datas):
				if (Utils.dataLength(datas) != input.length) {
					throw 'match too short!';
				} else {
					return Utils.dataJoin(datas);
				}
		};
	}
}
