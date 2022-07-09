import haxe.macro.Expr.Case;

class AstTools {
	public static function eval(ast:Ast) {
		return switch ast {
			case Number(val):
				val;
			case Binop("+", left, right): eval(left) + eval(right);
			case Binop("*", left, right): eval(left) * eval(right);
			case Group(val): eval(val);
			case _:
				throw "error in eval";
		}
	}
}
