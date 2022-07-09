package dectiss.lexer;

class Lexer {
	public static function lex(infos:Array<LexInfo>, content:String) {
		var pos = 0;
		var rowNumber = 0;
		var colNumber = 0;
		var tokens:Array<LexResult> = [];

		while (pos != content.length) {
			var check = false;

			for (info in infos) {
				if (info.rule.matchSub(content, pos) && info.rule.matchedPos().pos == pos) {
					var content = info.rule.matched(0);

					if (info.excludes != null && info.excludes.contains(content))
						continue;

					var lines = content.split("\n");

					tokens.push({
						name: info.name,
						text: content,
						value: if (info.value != null) info.value(info.rule) else content,
						rowNumber: rowNumber,
						colNumber: colNumber
					});

					pos += content.length;
					rowNumber += lines.length - 1;

					if (lines.length > 1) {
						colNumber = lines.pop().length;
					} else {
						colNumber += lines.pop().length;
					}

					check = true;
					break;
				}
			}

			if (!check) {
				throw 'no token found at ${content.substr(pos, 20)}';
			}
		}

		return tokens;
	}
}
