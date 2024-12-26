package dectiss.parser;

import dectiss.lexer.LexResult;
import dectiss.parser.ParseResult;

class Parser {
	/**
	 * The function entry point. It takes a rule and an array of tokens and returns the resulting AST.
	 * @param rule The rule to parse the tokens with.
	 * @param tokens The array of tokens to parse.
	 * @return The resulting AST.
	 */
	public static function parse<A>(rule:Rule<A>, tokens:Array<LexResult>):A {
		return switch rule(tokens, 0) {
			case {capture: AstMatch(value), size: s}:
				if (s == tokens.length) value else throw "error";
			case x:
				throw "error";
		};
	}

	/**
	 * Generates a rule that matches a token by its name then transforms it into an AST item.
	 * @param name The name of the token to match.
	 * @param transform A function that takes the matched token and returns an AST item.
	 * @return A rule that matches the token and transforms it with the given function.
	 */
	public static function token<A>(name:String, transform:(LexResult) -> A):Rule<A> {
		return (tokens:Array<LexResult>, index:Int) -> {
			if (tokens[index] != null && tokens[index].name == name) {
				return {capture: AstMatch(transform(tokens[index])), size: 1};
			}

			return {capture: NoMatch, size: 0};
		}
	}

	/**
	 * Generates a rule that matches a token by its name but throw the captured value. Usefull for things like whitespace or comments.
	 * @param name The name of the token to match.
	 * @param transform A function that takes the matched token and returns an AST item.
	 * @return A rule that matches the token with no data.
	 */
	public static function tokenThrow<A>(name:String):Rule<A> {
		return (tokens:Array<LexResult>, index:Int) -> {
			if (tokens[index] != null && tokens[index].name == name) {
				return {capture: ThrowMatch, size: 1};
			}

			return {capture: NoMatch, size: 0};
		}
	}

	/**
	 * Generate a rule that takes by taking an array of subrules that it will try to mtach in order. If any subrule fails, the wole rule fails. When succeeded, the captured tokens are the transformed into an AST item.
	 * @param rules The array of rules to match in order.
	 * @param transform A function to generate the AST item.
	 * @return Rule<A> A rule that matches an array of subrules.
	 */
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

/**
	 * Generate a rule that takes by taking an array of subrules that return the result of the first subrule that matches.
	 * @param rules That array of subrules.
	 * @return Rule<A> A rule that matches an array of subrules.
	 */
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

	/**
	 * Turns a rule into an optionnal one.
	 * @param rule the rule. 
	 * @return An optionnal rule.
	 */
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
