import dectiss.parser.ParseResult;
import dectiss.lexer.LexResult;
import dectiss.Utils;
import dectiss.lexer.LexInfo;
import js.html.Console;
import dectiss.lexer.Lexer;
import js.html.MouseEvent;
import js.html.DocumentFragment;
import js.Browser;
import Ast;

using AstTools;
using dectiss.parser.Parser;

class Test {
	static var numberRule = Parser.token("number", res -> Number(Std.parseInt(res.value)));
	static var spaceRule = Parser.tokenThrow("space");
	static var plusRule = Parser.tokenText("plus");
	static var valueRule = Parser.oneOf([groupRule, numberRule]);

	static function addRule(results:Array<LexResult>, index:Int):{capture:ParseResult<Ast>, size:Int} {
		return Parser.group([valueRule, spaceRule, plusRule, spaceRule, rootRule], group -> {
			return Binop(group[2].getText(), group[0].getResult(), group[4].getResult());
		})(results, index);
	}

	static function timesRule(results:Array<LexResult>, index:Int):{capture:ParseResult<Ast>, size:Int} {
		return Parser.group([valueRule, spaceRule, Parser.tokenText("times"), spaceRule, rootRule], group -> {
			return Binop(group[2].getText(), group[0].getResult(), group[4].getResult());
		})(results, index);
	}

	static function groupRule(results:Array<LexResult>, index:Int):{capture:ParseResult<Ast>, size:Int} {
		return Parser.group([Parser.tokenText("openPar"), rootRule, Parser.tokenText("closePar")], group -> {
			return Group(group[1].getResult());
		})(results, index);
	}

	static function rootRule(results:Array<LexResult>, index:Int):{capture:ParseResult<Ast>, size:Int} {
		return Parser.oneOf([addRule, timesRule, groupRule, numberRule])(results, index);
	}

	static function main() {
		var document = Browser.window.document;
		var fragment = new DocumentFragment();

		var compile = document.createButtonElement();
		compile.innerText = "compile";
		fragment.appendChild(compile);

		fragment.appendChild(document.createBRElement());

		var input = document.createTextAreaElement();
		input.cols = 80;
		input.rows = 50;
		fragment.appendChild(input);

		var result = document.createTextAreaElement();
		result.cols = 80;
		result.rows = 50;
		fragment.appendChild(result);

		document.body.appendChild(fragment);

		try {
			input.value = Browser.getLocalStorage().getItem("code");
		} catch (e:Dynamic) {}

		compile.addEventListener("click", (e:MouseEvent) -> {
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
					name: "times",
					rule: Utils.literralEReg("*"),
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
				var data = Lexer.lex(infos, input.value);
				Console.log(data);
				var ast = Parser.parse(rootRule, data);
				Console.log(ast);
				result.value = Std.string(ast.eval());
			} catch (e:String) {
				result.value = e;
			}

			return;
		});

		input.addEventListener("input", (e:Dynamic) -> {
			Browser.getLocalStorage().setItem("code", e.target.value);
			return;
		});
	}
}
