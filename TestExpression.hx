import dectiss.lexer.Lexer;
import dectiss.Utils;
import dectiss.lexer.LexInfo;
import dectiss.parser.ParseResult;
import Ast;
import dectiss.lexer.LexResult;

using dectiss.parser.Parser;
using AstTools;

class TestExpression {
	static var numberRule = Parser.token("number", res -> Number(Std.parseInt(res.value)));
	static var spaceRule = Parser.tokenThrow("space");
	static var plusRule = Parser.tokenText("plus");
	static var valueRule = Parser.oneOf([groupRule, numberRule]);

	static function binopRule(results:Array<LexResult>, index:Int):{capture:ParseResult<Ast>, size:Int} {
		return Parser.group([
			valueRule,
			optionnalSpaceRule,
			Parser.oneOf([
				Parser.tokenText("plus"),
				Parser.tokenText("minus"),
				Parser.tokenText("times"),
				Parser.tokenText("divide"),
				Parser.tokenText("module")
			]),
			optionnalSpaceRule,
			rootRule
		], group -> {
			return Binop(group[2].getText(), group[0].getResult(), group[4].getResult());
		})(results, index);
	}

	static function groupRule(results:Array<LexResult>, index:Int):{capture:ParseResult<Ast>, size:Int} {
		return Parser.group([Parser.tokenText("openPar"), rootRule, Parser.tokenText("closePar")], group -> {
			return Group(group[1].getResult());
		})(results, index);
	}

	static function optionnalSpaceRule(results:Array<LexResult>, index:Int):{capture:ParseResult<Ast>, size:Int} {
		return Parser.optionnal(Parser.tokenText("space"))(results, index);
	}

	static function rootRule(results:Array<LexResult>, index:Int):{capture:ParseResult<Ast>, size:Int} {
		return Parser.oneOf([binopRule, groupRule, numberRule])(results, index);
	}

	public static function parse(content:String):String {
		var infos:Array<LexInfo> = [
			{
				name: "space",
				rule: ~/\s+/m,
			},
			{
				name: "number",
				rule: ~/\d+/,
			},
			{
				name: "plus",
				rule: Utils.literralEReg("+"),
			},
			{
				name: "minus",
				rule: Utils.literralEReg("-"),
			},
			{
				name: "times",
				rule: Utils.literralEReg("*"),
			},
			{
				name: "divide",
				rule: Utils.literralEReg("/"),
			},
			{
				name: "modulo",
				rule: Utils.literralEReg("%"),
			},
			{
				name: "ident",
				rule: ~/[A-Za-z_][A-Za-z_0-9]*/,
				excludes: ["class"]
			},
			{
				name: "class",
				rule: Utils.literralEReg("class"),
			},
			{
				name: "openPar",
				rule: Utils.literralEReg("("),
			},
			{
				name: "closePar",
				rule: Utils.literralEReg(")"),
			}
		];
		try {
			var data = Lexer.lex(infos, content);
			trace(data);
			var ast = Parser.parse(TestExpression.rootRule, data);
			trace(ast);
			return Std.string(ast.eval());
		} catch (e:String) {
			return e;
		}
	}
}
