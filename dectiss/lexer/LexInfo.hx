package dectiss.lexer;

typedef LexInfo = {
	public var name:String;
	public var rule:EReg;
	public var ?value:(EReg) -> String;
	public var ?excludes:Array<String>;
}
