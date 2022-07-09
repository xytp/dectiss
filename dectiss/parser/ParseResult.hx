package dectiss.parser;

enum ParseResult<A> {
	NoMatch;
	ThrowMatch;
	TextMatch(content:String);
	AstMatch(value:A);
}
