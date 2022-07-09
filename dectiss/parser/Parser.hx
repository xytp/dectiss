package dectiss.parser;

import dectiss.lexer.LexResult;
import dectiss.parser.ParseResult;

class Parser {
	public static function parse<A>(rules:Rule<A>, tokens:Array<LexResult>):A {
		return switch rules(tokens, 0) {
			case {capture: AstMatch(value)}: value;
			case x:
				trace(x);
				throw "error";
		};
	}

	public static function token<A>(name:String, transform:(LexResult) -> A):Rule<A> {
		return (tokens:Array<LexResult>, index:Int) -> {
			if (tokens[index] != null && tokens[index].name == name) {
				return {capture: AstMatch(transform(tokens[index])), size: 1};
			}

			return {capture: NoMatch, size: 0};
		}
	}

	public static function tokenText<A>(name:String):Rule<A> {
		return (tokens:Array<LexResult>, index:Int) -> {
			if (tokens[index] != null && tokens[index].name == name) {
				return {capture: TextMatch(tokens[index].value), size: 1};
			}

			return {capture: NoMatch, size: 0};
		}
	}

	public static function tokenThrow<A>(name:String):Rule<A> {
		return (tokens:Array<LexResult>, index:Int) -> {
			if (tokens[index] != null && tokens[index].name == name) {
				return {capture: ThrowMatch, size: 1};
			}

			return {capture: NoMatch, size: 0};
		}
	}

	public static function group<A>(rules:Array<Rule<A>>, transform:(Array<ParseResult<A>>) -> A):Rule<A> {
		return (tokens:Array<LexResult>, index:Int) -> {
			var results:Array<ParseResult<A>> = [];
			var size = 0;

			for (rule in rules) {
				var res = rule(tokens, index + size);

				switch res.capture {
					case NoMatch: return res;
					default:
				}
				size += res.size;

				results.push(res.capture);
			}

			return {capture: AstMatch(transform(results)), size: size};
		}
	}

	public static function getText<A>(res:ParseResult<A>):String {
		return switch res {
			case TextMatch(text): text;
			case _:
				throw "error on getText";
		};
	}

	public static function getResult<A>(res:ParseResult<A>):A {
		return switch res {
			case AstMatch(value): value;
			case _:
				throw "error on getResult";
		};
	}

	public static function oneOf<A>(rules:Array<Rule<A>>):Rule<A> {
		return (tokens:Array<LexResult>, index:Int) -> {
			for (rule in rules) {
				var res = rule(tokens, index);
				switch res {
					case {capture: NoMatch}:
						continue;
					case _:
						return res;
				};
			}

			return {capture: NoMatch, size: 0}
		}
	}

	public static function optionnal<A>(rule:Rule<A>):Rule<A> {
		return (tokens:Array<LexResult>, index:Int) -> {
			var res = rule(tokens, index);
			return switch res {
				case {capture: NoMatch}:
					return {capture: EmptyMatch, size: 0};
				case _:
					return res;
			};
		}
	}
}
