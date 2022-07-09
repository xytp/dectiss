enum Ast {
	Number(val:Int);
	Group(val:Ast);
	Binop(op:String, left:Ast, right:Ast);
}
