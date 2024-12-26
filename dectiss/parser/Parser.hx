package dectiss.parser;

import dectiss.lexer.LexResult;
import dectiss.parser.ParseResult;

class Parser {
	public static function parse<A>(rule:Rule<A>, tokens:Array<LexResult>):A {
		return switch rule(tokens, 0) {
			case {capture: AstMatch(value), size: s}:
				if (s == tokens.length) value else throw "error";
			case x:
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
			var size = 0;
			var results:Array<ParseResult<A>> = [];

			for (rule in rules) {
				var res = rule(tokens, index + size);
				if (res.capture == NoMatch) return res;

				size += res.size;

				results.push(res.capture);
			}

			return {capture: AstMatch(transform(results)), size: size};
		}
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

	public static function getResult<A>(res:ParseResult<A>):A {
		return switch res {
			case AstMatch(value): value;
			case _: null;
		};
	}
}
